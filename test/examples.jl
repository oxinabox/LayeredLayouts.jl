module Examples
    using LightGraphs
    using SimpleWeightedGraphs
    medium_pert = SimpleDiGraph(Edge.([
        1 => 2
        1 => 3
        1 => 4
        1 => 5
        4 => 6
        5 => 6
        2 => 7
        3 => 7
        6 => 7
        3 => 8
        6 => 8
        6 => 9
        7 => 10
        8 => 10
        9 => 10
    10 => 11
    ]))

    chainrule_dependants = SimpleDiGraph(Edge.([
        1 => 2
        2 => 4
        2 => 5
        2 => 6
        3 => 2
        3 => 4
        3 => 7
        3 => 5
        3 => 8
        3 => 6
        4 => 9
        4 => 10
        4 => 11
    ]))
    

    two_lines = SimpleDiGraph(Edge.([
        1 => 3, 3=>5, 5=>7, 7=>9,
        2 => 4, 4=>6, 6=>8,
    ]))

    loop = SimpleDiGraph(Edge.([
        1 .=> [2, 3];
        2 => 4; 4 => 6;
        3 => 5; 5 => 7;
        [6, 7] .=> 8 
    ]))

    cross = SimpleDiGraph(Edge.([
        1 .=> [2, 3];
        2 .=> [3, 4];
        3 => 4;
    ]))

    xcross = SimpleDiGraph(Edge.([
        1 .=> [2, 3, 4];
        2 .=> [3, 4];
        3 => 4;
    ]))

    sankey_3twos = SimpleWeightedDiGraph(6)
    add_edge!(sankey_3twos, 1, 3, 1.0)
    add_edge!(sankey_3twos, 1, 4, 2.0)
    add_edge!(sankey_3twos, 2, 3, 3.0)
    add_edge!(sankey_3twos, 2, 4, 8.0)
    add_edge!(sankey_3twos, 3, 5, 3.0)
    add_edge!(sankey_3twos, 3, 6, 1.0)
    add_edge!(sankey_3twos, 4, 5, 10.0)
end
