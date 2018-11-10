# search.jl

alpha_beta_position = "6k1/5pb1/6p1/r2R4/8/2q5/1B3PP1/5RK1 w - - 0 1"

b = read_fen(alpha_beta_position)
printbd(b)



println("Testing best_move_alphabeta + quiescence ...")
bv, m, pv, nnodes, time_s = best_move_alphabeta(b, 0)
println(" 0\t $m\t $nnodes\t $time_s\t $(round(bv; digits=5))\t $m $(algebraic_format(pv))")
assert(long_algebraic_format(m) == "b2c3")

bv, m, pv, nnodes, time_s = best_move_alphabeta(b, 1)
println(" 1\t $m\t $nnodes\t $time_s\t $(round(bv; digits=5))\t $m $(algebraic_format(pv))")
assert(long_algebraic_format(m) == "d5d8")

bv, m, pv, nnodes, time_s = best_move_alphabeta(b, 2)
println(" 2\t $m\t $nnodes\t $time_s\t $(round(bv; digits=5))\t $m $(algebraic_format(pv))")
assert(long_algebraic_format(m) == "d5d8")

bv, m, pv, nnodes, time_s = best_move_negamax(b, 3)
println(" 3\t $m\t $nnodes\t $time_s\t $(round(bv; digits=5))\t $m $(algebraic_format(pv))")
assert(long_algebraic_format(m) == "d5d8")



println("Testing best_move_negamax ...")
bv, m, pv, nnodes, time_s = best_move_negamax(b, 0)
println(" 0\t $m\t $nnodes\t $time_s\t $(round(bv; digits=5))\t $m $(algebraic_format(pv))")
assert(long_algebraic_format(m) == "b2c3")

bv, m, pv, nnodes, time_s = best_move_negamax(b, 1)
println(" 1\t $m\t $nnodes\t $time_s\t $(round(bv; digits=5))\t $m $(algebraic_format(pv))")
assert(long_algebraic_format(m) == "b2c3")

bv, m, pv, nnodes, time_s = best_move_negamax(b, 2)
println(" 2\t $m\t $nnodes\t $time_s\t $(round(bv; digits=5))\t $m $(algebraic_format(pv))")
assert(long_algebraic_format(m) == "d5d8")

bv, m, pv, nnodes, time_s = best_move_negamax(b, 3)
println(" 3\t $m\t $nnodes\t $time_s\t $(round(bv; digits=5))\t $m $(algebraic_format(pv))")
assert(long_algebraic_format(m) == "d5d8")
