
ref(fn) = joinpath(@__DIR__, "references", fn * ".png")

xs, ys = solve_positions(LayeredMinDistOne(), Examples.medium_pert)

@plottest quick_plot(Examples.medium_pert, xs, ys) ref("1")