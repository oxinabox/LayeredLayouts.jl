is_dag(g) = is_directed(g) && !is_cyclic(g)
dag_or_error(g) = is_dag(g) || throw(DomainError(g, "Only Directed Acylic Graphs are supported"))


sources(graph) = findall(iszero, indegree(graph))
sinks(graph) = findall(iszero, outdegree(graph))

function longest_paths(graph, roots)
    dag_or_error(graph)
    dists = zeros(nv(graph))
    pending = [0 => r for r in roots]
    while(!isempty(pending))
        depth, node = pop!(pending)
        dists[node] = max(dists[node], depth) + 1  # +1 to make 1-based layer ordering
        append!(pending, (depth+1) .=> outneighbors(graph, node))
    end
    return dists
end