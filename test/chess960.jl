# chess960.jl

using Random

function chess960()
    print("Testing chess960: ")
    Random.seed!(0)
    ngames = 500
    max_number_of_moves_per_game = 100
    for i in 1:ngames
        b = new_game_960()
        println("Game $i FEN $(write_fen(b))")
        printbd(b)
        for j in 1:max_number_of_moves_per_game
            moves = generate_moves(b)
            test_board = deepcopy(b)
            for m in moves
                make_move!(test_board, m)
                unmake_move!(test_board, m, b.castling_rights,
                                            b.last_move_pawn_double_push)
                if write_fen(test_board)!=write_fen(b)
                    printbd(b)
                    println(algebraic_format(m))
                    printbd(test_board)
                    @assert false "$(algebraic_format(m)) not correctly undone"
                end
            end
            if length(moves)==0
                break
            end
            m = moves[rand(1:length(moves))]
            print(algebraic_format(m) * " ")
            make_move!(b, m)
        end
        println()
        println()
    end
    println()
end

chess960()

function move_error()
    # error discovered in random play, pawn move leaves a invalid square piece color
    b = Chess.read_fen("r2krnb1/1pq1pppp/3p4/p1p1n3/4PP2/3NN2P/P1PP1BP1/RBQKR3 b KQkq -")
    Chess.make_move!(b, "g2g3")
    printbd(b)
end
