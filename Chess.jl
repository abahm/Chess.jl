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


if "-uci" ∈ ARGS
    uci_loop()
elseif "-xboard" ∈ ARGS
    xboard_loop()
else
    depth = 2
    play(depth)
end


end
