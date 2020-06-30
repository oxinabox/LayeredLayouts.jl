module Examples
    using LightGraphs
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
end