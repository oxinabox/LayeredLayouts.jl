# This contains algorithms for breaking up a DAG into layers
"Calculate the layer of each node"
function layer_by_longest_path_to_source(graph, opt_layer_assign)
    dists = longest_paths(graph, sources(graph))
    layer_groups = collect.(IterTools.groupby(i->dists[i], sort(vertices(graph), by=i->dists[i])))
    agree_with_opt_layer_assign!(layer_groups, graph, opt_layer_assign)
    return layer_groups
end

"Correct the layer of each node, according to the optional parameter by user"
function agree_with_opt_layer_assign!(layer_groups, graph, opt_layer_assign)
    if length(opt_layer_assign) > 0
        key_opt = collect(keys(opt_layer_assign))
        values_opt = collect(values(opt_layer_assign))

        opt_ids_by_layers = sortperm(collect(values(opt_layer_assign)), rev=true)
        key_opt = key_opt[opt_ids_by_layers]
        values_opt = values_opt[opt_ids_by_layers]

        # change layers if needed
        for (k, l) in zip(key_opt, values_opt)
            #current layer of node
            curr_layer = findfirst(k .∈ layer_groups)
            if !isnothing(curr_layer)
                if curr_layer >= l
                    @warn "Ignored opt_layer_assign for node $k; dists[k] ($(dists[k])) > l ($l)"
                elseif any(has_edge(graph, k, v) for v in vcat(layer_groups[curr_layer:l]...))
                    error("opt_layer_assign node $k incompatible with edge order")
                else
                    filter!(x->x != k, layer_groups[curr_layer])
                    push!(layer_groups[l], k)
                end
            end
        end
    end
end


###################
# helpers


function node2layer_lookup(layer2nodes)
    flat_map = [node=>layer_ind for (layer_ind, nodes) in enumerate(layer2nodes) for node in nodes]
    sort!(flat_map)
    @assert first.(flat_map) == 1:length(flat_map)
    return last.(sort(flat_map))
end

"add nodes so that no edges span multiple layers, returns mask"
function add_dummy_nodes!(graph, layer2nodes)
    dag_or_error(graph)
    nondummy_nodes = vertices(graph)
    # mapping from edges in the original graph to paths in the graph with dummy nodes
    edge_to_paths = Dict(e => eltype(graph)[] for e in edges(graph))
    node2layer = node2layer_lookup(layer2nodes)  # doesn't have dummy nodes, doesn't need them
    for cur_node in vertices(graph)
        cur_layer = node2layer[cur_node]
        for out_edge in filter(e -> src(e) == cur_node, collect(edges(graph)))  # need to copy as outwise will mutate when the graph is mutated
            out_node = out_edge.dst
            out_layer = node2layer[out_node]
            cur_layer < out_layer || throw(DomainError(node2layer, "Layer assigmenment must be strictly monotonic"))
            path = get!(edge_to_paths, out_edge, eltype(graph)[])
            if out_layer != cur_layer + 1
                rem_edge!(graph, cur_node, out_node) || error("removing edge failed")
                prev_node = cur_node
                push!(path, prev_node)
                for step_layer in (cur_layer + 1) : (out_layer - 1)
                    add_vertex!(graph) || throw(OverflowError("Could not add vertices to graph."))
                    step_node = nv(graph)
                    push!(layer2nodes[step_layer], step_node)
                    add_edge!(graph, prev_node, step_node)
                    push!(path, step_node)
                    prev_node = step_node
                end
                add_edge!(graph, prev_node, out_node)
                push!(path, out_node)
            else
                push!(path, cur_node, out_node)
            end
        end
    end
    is_dummy_mask = trues(nv(graph))
    is_dummy_mask[nondummy_nodes] .= false
    return is_dummy_mask, edge_to_paths
end
