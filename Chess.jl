# chess.jl

module Chess

const version = "Julia Chess, v0.35"
const author = "Alan Bahm"


export WHITE, BLACK
export KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN
export A, B, C, D, E, F, G, H
export square
export CASTLING_RIGHTS_ALL
export generate_moves, make_move!
export print_algebraic
export Board, set!, new_game, read_fen, printbd
export perft, perft_data
export play, random_play_both_sides

include("constants.jl")
include("util.jl")
include("move.jl")
include("board.jl")
include("position.jl")
include("evaluation.jl")
include("search.jl")
include("ui.jl")
include("protocols/xboard.jl")
include("protocols/uci.jl")


function test_undo_move()
    srand(0)
    ngames = 500
    max_number_of_moves_per_game = 100
    for i in 1:ngames
        b = new_game()
        for j in 1:max_number_of_moves_per_game
            moves = generate_moves(b)
            test_board = deepcopy(b)
            for m in moves
                make_move!(test_board, m)
                unmake_move!(test_board, m, b.castling_rights,
                                            b.last_move_pawn_double_push)
                if write_fen(test_board)!=write_fen(b)
                    printbd(b)
                    println(algebraic_move(m))
                    printbd(test_board)
                    @assert false "$(algebraic_move(m)) not correctly undone"
                end
            end
            if length(moves)==0
                break
            end
            m = moves[rand(1:length(moves))]
            print(algebraic_move(m) * " ")
            make_move!(b, m)
        end
        println()
    end
end

test_undo_move()


#=
if "-uci" ∈ ARGS
    uci_loop()
elseif "-xboard" ∈ ARGS
    xboard_loop()
else
    depth = 2
    play(depth)
end
=#

end
