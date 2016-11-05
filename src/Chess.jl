# chess.jl

module Chess

const version = "Julia Chess, v0.37"
const author = "Alan Bahm"


include("constants.jl")
include("util.jl")
include("move.jl")
include("board.jl")
include("position.jl")
include("evaluation.jl")
include("search.jl")
include("play.jl")
include("protocols/xboard.jl")
include("protocols/uci.jl")


if "-uci" ∈ ARGS
    uci_loop()
elseif "-xboard" ∈ ARGS
    xboard_loop()
elseif "-repl" ∈ ARGS
    repl_loop()
end

export WHITE, BLACK
export KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN
export A, B, C, D, E, F, G, H
export square
export CASTLING_RIGHTS_ALL
export generate_moves, make_move!, unmake_move!
export Move, algebraic_move
export Board, set!, new_game, new_game_960
export read_fen, write_fen, printbd
export play, random_play_both_sides, perft


end
