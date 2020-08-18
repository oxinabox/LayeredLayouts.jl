"""
    OptimalSugiyama

# Fields
 - `time_limit::Dates.Period`: how long to spend trying alternative orderings.
   There are often many possible orderings that have the same amount of crossings.
   There is a chance that one of these will allow a better arrangement than others.
   Mostly the first solution tends to be very good.
   By setting a `time_limit > Second(0)`, multiple will be tried til the time limit is exceeded.
   (Note: that this is not a maximum time, but rather a limit that once exceeded no more
   attempts will be made.).
   If you have a `time_limit` greater than `Second(0)` set then the result is no longer determenistic.
   Note also that this is heavily affected by first call compilation time.
"""
struct OptimalSugiyama <: AbstractLayout
    time_limit::Dates.Period
end
OptimalSugiyama() = OptimalSugiyama(Dates.Second(1))

function solve_positions(layout::OptimalSugiyama, original_graph)
    graph = copy(original_graph)

    # 1. Layer Assigment
    layer2nodes = layer_by_longest_path_to_source(graph)
    is_dummy_mask = add_dummy_nodes!(graph, layer2nodes)

    # 2. Layer Ordering
    start_time = Dates.now()
    min_total_distance = Inf
    min_num_crossing = Inf
    local best_pos
    ordering_model, is_before = ordering_problem(layout, graph, layer2nodes)
    for round in 1:typemax(Int)
        round > 1 && forbid_solution!(ordering_model, is_before)

        optimize!(ordering_model)
        # No need to keep banning solutions if not finding optimal ones anymore
        termination_status(ordering_model) != MOI.OPTIMAL && break
        num_crossings = objective_value(ordering_model)
        # we are not interested in arrangements that have more crossings, only in 
        # alternatives with same number of crossings.
        num_crossings > min_num_crossing && break
        min_num_crossing = num_crossings
        order_layers!(layer2nodes, is_before)

        # 3. Node Arrangement
        xs, ys, total_distance = assign_coordinates(graph, layer2nodes)
        if total_distance < min_total_distance
            min_total_distance = total_distance
            best_pos = (xs, ys)
        end
        Dates.now() - start_time > layout.time_limit && break
    end
    xs, ys = best_pos
    return xs[.!is_dummy_mask], ys[.!is_dummy_mask] 
end

"""
    ordering_problem(::OptimalSugiyama, graph, layer2nodes)

Formulates the problem of working out optimal ordering as a MILP.

Returns:
 - `model::Model`: the JuMP model that when optized will find the optimal ordering
 - `is_before::AbstractVector{AbstractVector{Variable}}`: the variables of the model,
   which once solved will have `value(is_before[n1][n2]) == true` 
   if `n1` is best arrange before `n2`.
"""
function ordering_problem(::OptimalSugiyama, graph, layer2nodes)
    m = Model(Cbc.Optimizer)
    set_silent(m)

    T = JuMP.Containers.DenseAxisArray{VariableRef,1,Tuple{Vector{Int64}},Tuple{Dict{Int64,Int64}}}
    node_is_before = Vector{T}(undef, nv(graph))
    for (layer, nodes) in enumerate(layer2nodes)
        before = @variable(m, [nodes, nodes], Bin, base_name="befores_$layer")
        for n1 in nodes
            node_is_before[n1] = before[n1, :]
            for n2 in nodes
                n1 === n2 && continue
                # can't have n1<n2 and n2<n1
                @constraint(m, before[n1, n2] + before[n2, n1] == 1)
                for n3 in nodes
                    (n1 === n3 || n2 === n3) && continue
                    # at most two of these 3 hold
                    @constraint(m , before[n1, n2] + before[n2, n3] + before[n3, n1] <= 2)
                end
            end
        end
    end

    weights_mat = weights(graph)
    function crossings(src_layer)
        total = AffExpr(0)
        for src1 in src_layer, src2 in src_layer
            for dst1 in outneighbors(graph, src1), dst2 in outneighbors(graph, src2)
                # Can't cross if share end-point 
                (src1 === src2 || dst1 === dst2) && continue
                crossing = @variable(m, binary=true, base_name="cross $src1-$dst2 x $src1-$dst2")
                # two edges cross if the src1 is before scr2; but dst1 is after dest2
                @constraint(m, node_is_before[src1][src2] + node_is_before[dst2][dst1] - 1 <= crossing)
                
                # for Sankey diagrams we minimise not just crossing but area of crossing
                # treating the weights of the graph as the widths of the line and ignoring skew
                w1 = weights_mat[src1, dst1]
                w2 = weights_mat[src2, dst2]
                area = w1*w2
                add_to_expression!(total, area, crossing)
            end
        end
        return total
    end

    @objective(m, Min, sum(crossings, layer2nodes))
    return m, node_is_before
end
    


function order_layers!(layer2nodes, is_before)
    # Cunning trick: we need to go from the `before` matrix to an actual order list
    # we can do this by sorting when having `lessthan` read from the `before` matrix
    is_before_func(n1, n2) = Bool(value(is_before[n1][n2]))
    for layer in layer2nodes
        sort!(layer; lt=is_before_func)
    end
    return layer2nodes
end

"""
    forbid_solution!(m, is_before)

Modifies the JuMP model `m` to forbid the solution present in `is_before`.
`is_before` must contain solved variables.
"""
function forbid_solution!(m, is_before)
    cur_trues = AffExpr(0)
    total_trues = 0
    for var_list in is_before
        for var in var_list
            if value(var) > 0.5 
                add_to_expression!(cur_trues, var)
                total_trues += 1
            end
        end
    end
    # for it to be a different order some of the ones that are currently true must swap to being false
    @constraint(m, sum(cur_trues) <= total_trues - 1)
        
    return m
end

"""
    assign_coordinates(graph, layer2nodes)

Works out the `x` and `y` coordinates for each node in the `graph`.
This is via formulating the problem as a QP, and minimizing total distance
of links.
It maintains the order given in `layer2nodes`s.
returns: `xs, ys, total_distance`
"""
function assign_coordinates(graph, layer2nodes)
    m = Model(Ipopt.Optimizer)
    set_silent(m)
    set_optimizer_attribute(m, "print_level", 0)  # TODO this can be deleted once the version of IPOpt that actually supports `set_silent` is released

    node2y = Dict{Int, VariableRef}()
    for (layer, nodes) in enumerate(layer2nodes)
        prev_y = -1.0
        for node in nodes
            # each must be greater than the last, with a gap of 1 unit
            y = @variable(m, base_name="y_$node")
            @constraint(m, prev_y + 1.0 <= y)
            node2y[node] = y
            prev_y = y
        end
    end

    weights_mat = weights(graph)
    total_distance = QuadExpr(AffExpr(0.0))
    for cur in vertices(graph)
        for out in outneighbors(graph, cur)
            w = weights_mat[cur, out]
            distance = (node2y[cur] - node2y[out])^2
            add_to_expression!(total_distance, w, distance)
        end 
    end

    @objective(m, Min, total_distance);
    optimize!(m)
    score = objective_value(m)

    ###
    xs = Vector{Float64}(undef, nv(graph))
    ys = Vector{Float64}(undef, nv(graph))
    for (xi, nodes) in enumerate(layer2nodes)
        for node in nodes
            xs[node] = xi
            ys[node] = value(node2y[node])
        end
    end
    return xs, ys, score
end