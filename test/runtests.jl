# runtests.jl

# put Chess.jl in your load path (for this session only)
if pwd()∉LOAD_PATH  push!(LOAD_PATH, pwd())  end
# load the Chess.jl module for testing
using Chess

tic()

include("undo_move.jl")
include("generate_moves.jl")
include("pinned.jl")
include("mates.jl")


println("Tests complete!")
toc()
