# chess.jl

println("Welcome to Julia Chess, v0.01")

module Chess

export perft, perft_data
export new_game, read_fen, printbd
export random_play_both_sides, user_play_both_sides

include("constants.jl")
include("util.jl")
include("move.jl")
include("board.jl")
include("position.jl")
include("uci.jl")

end
