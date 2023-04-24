var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = LayeredLayouts","category":"page"},{"location":"#LayeredLayouts","page":"Home","title":"LayeredLayouts","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [LayeredLayouts]","category":"page"},{"location":"#LayeredLayouts.Zarate","page":"Home","title":"LayeredLayouts.Zarate","text":"Zarate\n\nA Sugiyaqma style layout for DAGs and Sankey diagrams. Based on\n\nZarate, D. C., Le Bodic, P., Dwyer, T., Gange, G., & Stuckey, P. (2018, April). Optimal sankey diagrams via integer programming. In 2018 IEEE Pacific Visualization Symposium (PacificVis) (pp. 135-139). IEEE.\n\nFields\n\ntime_limit::Dates.Period: how long to spend trying alternative orderings. There are often many possible orderings that have the same amount of crossings. There is a chance that one of these will allow a better arrangement than others. Mostly the first solution tends to be very good. By setting a time_limit > Second(0), multiple will be tried until the time limit is exceeded. (Note: that this is not a maximum time, but rather a limit that once exceeded no more attempts will be made.). If you have a time_limit greater than Second(0) set then the result is no longer deterministic. Note also that this is heavily affected by first call compilation time.\n\n\n\n\n\n","category":"type"},{"location":"#LayeredLayouts.add_dummy_nodes!-Tuple{Any, Any}","page":"Home","title":"LayeredLayouts.add_dummy_nodes!","text":"add nodes so that no edges span multiple layers, returns mask\n\n\n\n\n\n","category":"method"},{"location":"#LayeredLayouts.assign_coordinates-Tuple{Any, Any, Any}","page":"Home","title":"LayeredLayouts.assign_coordinates","text":"assign_coordinates(layout, graph, layer2nodes; force_equal_layers)\n\nWorks out the x and y coordinates for each node in the graph. This is via formulating the problem as a QP, and minimizing total distance of links. It maintains the order given in layer2nodess. force_equal_layers enforces equal y-positions across paired nodes in specified layers. returns: xs, ys, total_distance\n\n\n\n\n\n","category":"method"},{"location":"#LayeredLayouts.forbid_solution!-Tuple{Any, Any}","page":"Home","title":"LayeredLayouts.forbid_solution!","text":"forbid_solution!(m, is_before)\n\nModifies the JuMP model m to forbid the solution present in is_before. is_before must contain solved variables.\n\n\n\n\n\n","category":"method"},{"location":"#LayeredLayouts.force_layers!-Tuple{Any, Any, Vector{Pair{Int64, Int64}}}","page":"Home","title":"LayeredLayouts.force_layers!","text":"Correct the layer of each node, according to the optional parameter by user\n\n\n\n\n\n","category":"method"},{"location":"#LayeredLayouts.layer_by_longest_path_to_source-Tuple{Any, Any}","page":"Home","title":"LayeredLayouts.layer_by_longest_path_to_source","text":"Calculate the layer of each node\n\n\n\n\n\n","category":"method"},{"location":"#LayeredLayouts.ordering_problem-Tuple{Zarate, Any, Any}","page":"Home","title":"LayeredLayouts.ordering_problem","text":"ordering_problem(::Zarate, graph, layer2nodes; force_order, force_equal_layers)\n\nFormulates the problem of working out optimal ordering as a MILP.\n\nReturns:\n\nmodel::Model: the JuMP model that when optized will find the optimal ordering\nis_before::Dict{Pair{Int, Int}, VariableRef}: the variables of the model, which once solved will have value(is_before[n1=>n2]) == true if n1 is best arranged before n2.\n\n\n\n\n\n","category":"method"},{"location":"#LayeredLayouts.solve_positions-Tuple{Zarate, Any}","page":"Home","title":"LayeredLayouts.solve_positions","text":"solve_positions(::Zarate, graph; force_layer, force_order, force_equal_layers)\n\nReturns:\n\nxs: the xs coordinates of vertices in the layout\nys: the ys coordinates of vertices in the layout\npaths: a Dict which, for each edge in graph, contains a Tuple of coordinate vectors (xs, ys).\n\nThe layout is calculated on a graph where dummy nodes can be added to the different layers. As a result, plotting edges as straight lines between two nodes can result in more crossings than optimal : edges should instead be routed through these different dummy nodes. paths contains for each edge, a Tuple of vectors, representing that route through the different nodes as x and y coordinates.\n\nOptional arguments:\n\nforce_layer: Vector{Pair{Int, Int}}     specifies the layer for each node     e.g. [3=>1, 5=>5] specifies layer 1 for node 3 and layer 5 to node 5\n\nforce_order: Vector{Pair{Int, Int}}     this vector forces the ordering of the nodes in each layer,     e.g. force_order = [3=>2, 1=>3] forces node 3 to lay before node 2, and node 1 to lay before node 3\n\nforce_equal_layers: Vector{Pair{Int, Int}}     force the nodes of distinct layers to have identical y-positions.     e.g. force_equal_layers = [i=>j, …] specifies that the node orderings and     y-positions in layers i and j must be equal; note that the number of nodes in layers     i and j must be identical.\n\nExample:\n\nusing Graphs, Plots\n\ng = random_orientation_dag(complete_graph(5))\nxs, ys, paths = solve_positions(Zarate(), g)\nscatter(xs, ys)\nfor e in edges(g)\n    e_xs, e_ys = paths[e]\n    plot!(e_xs, e_ys)\nend\n\n\n\n\n\n","category":"method"},{"location":"#LayeredLayouts.try_get-Tuple{Nothing, Vararg{Any}}","page":"Home","title":"LayeredLayouts.try_get","text":"try_get(collection, inds...)\n\nLike getindex, except returns nothing if not found or if the collection itsself is nothing.\n\n\n\n\n\n","category":"method"}]
}
