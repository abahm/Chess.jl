# runtests.jl

include("chess.jl")

println("Running perft 1-5")
@assert Chess.perft(Chess.new_game(), 1) == 20
@assert Chess.perft(Chess.new_game(), 2) == 400
@assert Chess.perft(Chess.new_game(), 3) == 8902 "perft 3 gives $(Chess.perft(Chess.new_game(), 3)) instead of 8092"
@assert Chess.perft(Chess.new_game(), 4) == 197281 "perft 4 gives $(Chess.perft(Chess.new_game(), 3)) instead of 197281"
@assert Chess.perft(Chess.new_game(), 5) == 4865609 "perft 5 gives $(Chess.perft(Chess.new_game(), 3)) instead of 4865609"
