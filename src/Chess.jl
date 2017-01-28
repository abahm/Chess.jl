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

const version = "Julia Chess, v0.52"
const author = "Alan Bahm"


include("Zobrist.jl")
include("constants.jl")
include("util.jl")
include("move.jl")
include("movelist.jl")
include("board.jl")
#include("position_original.jl")
include("position.jl")
include("evaluation.jl")
include("search.jl")
#include("play_original.jl")
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



function test_refactor()
    println()
    b = new_game()
    #b = read_fen("k7/8/8/8/8/8/8/K7 w - - 0 1")
    println()
    printbd(b)
    @show b.game_movelist

    moves = generate_moves(b)
    #@show b.game_movelist

    node_count = perft(b, 4)
    println(node_count)
    println()
    printbd(b)

    #=
    moves = generate_moves(b)
    for (i,move) in enumerate(moves)
        if i > number_of_moves(b.game_movelist)
            break
        end
        println(algebraic_format(move))
    end


    move = moves[1]

    prior_castling_rights = b.castling_rights
    prior_last_move_pawn_double_push = b.last_move_pawn_double_push
    make_move!(b, move)
    #node_count = perft(b, levels)
    unmake_move!(b, move, prior_castling_rights,
                          prior_last_move_pawn_double_push)


    printbd(b)
    moves = generate_moves(b)
    for (i,move) in enumerate(moves)
        if i > number_of_moves(b.game_movelist)
            break
        end
        println(algebraic_format(move))
    end
    =#
end

test_refactor()


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
