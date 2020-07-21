struct Sugiyama <: AbstractLayout
end

function solve_positions(layout::Sugiyama, original_graph)
    graph = copy(original_graph)
    layer2nodes = layer_by_longest_path_to_source(graph)
    is_dummy_mask = add_dummy_nodes!(graph, layer2nodes)

    order_layers!(graph, layer2nodes)

    xs, ys = assign_coordinates(graph, layer2nodes)
    return xs[.!is_dummy_mask], ys[.!is_dummy_mask] 
end


function order_layers!(graph, layer2nodes)
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

    befores_vars = all_variables(m)  # before we add crossing variables

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
    optimize!(m)
    @show termination_status(m)
    @show objective_value(m)

    # for debugging of solutions  #############
    global last_m = m
    global last_befores_vars = befores_vars
    #############################
    
    # Cunning trick: we need to go from the `before` matrix to an actual order list
    # we can do this by sorting when having `lessthan` read from the `before` matrix
    is_before_func(n1, n2) = Bool(value(node_is_before[n1][n2]))
    for layer in layer2nodes
        #==
        for n1 in layer, n2 in layer
            n1 === n2 && continue
            is_before = Bool(value(node_is_before[n1][n2]))
            is_before && println("$n1 < $n2")
        end
        ==#
        sort!(layer; lt=is_before_func)
    end    
end

function find_next_best_solution!(m, befores_vars)
    cur_trues = AffExpr(0)
    total_trues = 0
    for var in befores_vars(m)
        if Bool(value(var)) 
            add_to_expression!(cur_trues, var)
            total_trues += 1
            print(var)
        end
    end
    # for it to be a different order some of the ones that are currently true must swap to being false
    @constraint(m, sum(cur_trues) <= total_trues - 1)
        
    optimize!(m)
    @show termination_status(m)
    @show objective_value(m)
end

function assign_coordinates(graph, layer2nodes)
    xs = Vector{Float64}(undef, nv(graph))
    ys = Vector{Float64}(undef, nv(graph))
    for (xi, layer) in enumerate(layer2nodes)
        for (yi, node) in enumerate(layer)
            xs[node] = xi
            ys[node] = yi - length(layer)/2
        end
    end
    return xs, ys
end