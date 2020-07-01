@testset "medium_pert" begin
    xs, ys = solve_positions(LayeredMinDistOne(), Examples.medium_pert)
    @plottest quick_plot(Examples.medium_pert, xs, ys) ref"medium_pert"
end