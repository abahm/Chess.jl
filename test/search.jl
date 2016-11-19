# search.jl

alpha_beta_position = "6k1/5pb1/6p1/r2R4/8/2q5/1B3PP1/5RK1 w - - 0 1"

b = read_fen(alpha_beta_position)
printbd(b)

println("Testing best_move_negamax ...")
best_value, best_move, principal_variation, number_nodes_visited, t_s = best_move_negamax(b, 0)
@show 0, best_move, number_nodes_visited, t_s, principal_variation, round(best_value,2)
assert(long_algebraic_format(best_move) == "b2c3")

best_value, best_move, principal_variation, number_nodes_visited, t_s = best_move_negamax(b, 1)
@show 1, best_move, number_nodes_visited, t_s, principal_variation, round(best_value,2)
assert(long_algebraic_format(best_move) == "b2c3")

best_value, best_move, principal_variation, number_nodes_visited, t_s = best_move_negamax(b, 2)
@show 2, best_move, number_nodes_visited, t_s, principal_variation, round(best_value,2)
assert(long_algebraic_format(best_move) == "d5d8")

best_value, best_move, principal_variation, number_nodes_visited, t_s = best_move_negamax(b, 3)
@show 3, best_move, number_nodes_visited, t_s, principal_variation, round(best_value,2)
assert(long_algebraic_format(best_move) == "d5d8")



println("Testing best_move_alphabeta ...")
best_value, best_move, principal_variation, number_nodes_visited, t_s = best_move_alphabeta(b, 0)
@show 0, best_move, number_nodes_visited, t_s, principal_variation, round(best_value,2)
assert(long_algebraic_format(best_move) == "b2c3")

best_value, best_move, principal_variation, number_nodes_visited, t_s = best_move_alphabeta(b, 1)
@show 1, best_move, number_nodes_visited, t_s, principal_variation, round(best_value,2)
assert(long_algebraic_format(best_move) == "b2c3")

best_value, best_move, principal_variation, number_nodes_visited, t_s = best_move_alphabeta(b, 2)
@show 2, best_move, number_nodes_visited, t_s, principal_variation, round(best_value,2)
assert(long_algebraic_format(best_move) == "d5d8")

best_value, best_move, principal_variation, number_nodes_visited, t_s = best_move_negamax(b, 3)
@show 3, best_move, number_nodes_visited, t_s, principal_variation, round(best_value,2)
assert(long_algebraic_format(best_move) == "d5d8")
