# Chess.jl

module Chess

# Why use Julia for a chess engine?
#
# advantages of Julia:
#  1 metaprogramming, ability to reduce repeated code by macros
#  2 mulitiple dispatch, ability to create functs distinguished by signature
#  3 designed for parallelism, multicore
#
#  4 ... at big picture level, experiment with larger ideas easily
#

const version = "Julia Chess, v0.50"
const author = "Alan Bahm"


include("Zobrist.jl")
include("constants.jl")
include("util.jl")
include("move.jl")
include("board.jl")
include("movelist.jl")
include("position.jl")
include("evaluation.jl")
include("search.jl")
include("play.jl")
include("protocols/xboard.jl")
include("protocols/uci.jl")


if "-uci" ∈ ARGS
    # not yet supported...
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
export Move, algebraic_format, long_algebraic_format
export Board, set!, new_game, new_game_960
export read_fen, write_fen, printbd
export play, random_play_both_sides, perft
export best_move_search, best_move_negamax, best_move_alphabeta

end
