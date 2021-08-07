# This contains algorithms for breaking up a DAG into layers
"Calculate the layer of each node"
function layer_by_longest_path_to_source(graph, force_layer)
    dists = longest_paths(graph, sources(graph))
    force_layers!(graph, dists, force_layer)
    layer_groups = collect.(IterTools.groupby(i->dists[i], sort(vertices(graph), by=i->dists[i])))
    return layer_groups
end

"Correct the layer of each node, according to the optional parameter by user"
function force_layers!(graph, dists, force_layer::Vector{Pair{Int, Int}})
    # must process from end to beginning as otherwise can't move things after to make space
    ordered_forced_layers = sort(collect(force_layer), by=last; rev=true)
    for (node_id, target_layer) in ordered_forced_layers
        curr_layer = dists[node_id]
        if target_layer < curr_layer
            @warn "Ignored force_layer for node $node_id; curr layer ($curr_layer) > desired layer ($target_layer)"
        elseif any(dists[child] <= target_layer for child in outneighbors(graph, node_id))
            @warn "Ignored force_layer for node $node_id; as placing it at $target_layer would place it on same layer, or later than it's children."
        else
            dists[node_id] = target_layer
        end
    end
    return dists
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
