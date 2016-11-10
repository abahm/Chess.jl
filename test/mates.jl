# mates.jl


# https://sites.google.com/site/darktemplarchess/mate-in-2-puzzles
mate_info = [
("2bqkbn1/2pppp2/np2N3/r3P1p1/p2N2B1/5Q2/PPPPKPP1/RNB2r2 w KQkq - 0 1", 3, "f3f7"),
("8/6K1/1p1B1RB1/8/2Q5/2n1kP1N/3b4/4n3 w - - 0 1", 3, "d6a3"),
("B7/K1B1p1Q1/5r2/7p/1P1kp1bR/3P3R/1P1NP3/2n5 w - - 0 1", 3, "a8c6"),
("8/8/8/8/8/7k/6rr/K7 b  -", 1, "g2g1")
]

function mates()
    for mate in mate_info
        b = read_fen(mate[1])
        ply = mate[2]
        winning_move = mate[3]
        printbd(b)
        score, move, pv, number_nodes_visited, time_s = best_move_search(b, ply)
        println("$score $(algebraic_format(move)) $(algebraic_format(pv))")
        println("$ply   $number_nodes_visited nodes  $(round(time_s,4)) s  $(round(number_nodes_visited/(time_s*1000),2)) kn/s")
        @assert long_algebraic_format(move)==winning_move "Should be $winning_move"
        println()
    end
end

mates()
