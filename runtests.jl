# runtests.jl

using Chess


println("Running perft 1-5")
@assert perft(new_game(), 1) == 20
@assert perft(new_game(), 2) == 400
@assert perft(new_game(), 3) == 8902 "perft 3 gives $(perft(new_game(), 3)) instead of 8092"
@assert perft(new_game(), 4) == 197281 "perft 4 gives $(perft(new_game(), 4)) instead of 197281"
@assert perft(new_game(), 5) == 4865609 "perft 5 gives $(perft(new_game(), 5)) instead of 4865609"
