# chess.jl

println("Welcome to Julia Chess, v0.10")

module Chess

export WHITE, BLACK
export KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN
export A, B, C, D, E, F, G, H
export square
export CASTLING_RIGHTS_ALL
export generate_moves, make_move!
export print_algebraic
export Board, set!, new_game, read_fen, printbd
export perft, perft_data
export random_play_both_sides, user_play_both_sides

include("constants.jl")
include("util.jl")
include("move.jl")
include("board.jl")
include("position.jl")
include("uci.jl")



# start up an interactive board
#user_play_both_sides()


end
