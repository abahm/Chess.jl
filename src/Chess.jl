# chess.jl

module Chess

const version = "Julia Chess, v0.36"
const author = "Alan Bahm"


export WHITE, BLACK
export KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN
export A, B, C, D, E, F, G, H
export square
export CASTLING_RIGHTS_ALL
export generate_moves, make_move!, unmake_move!
export print_algebraic, algebraic_move
export Board, set!, new_game, read_fen, write_fen, printbd
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
    play()
end


end
