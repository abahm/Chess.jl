# runtests.jl

# put Chess.jl in your load path (for this session only)
#chess_dir = pwd()*"/.."
#@show chess_dir
#if chess_dir∉LOAD_PATH  push!(LOAD_PATH, chess_dir)  end

# load the Chess.jl module for testing
using Chess

tic()

include("undo_move.jl")
include("generate_moves.jl")
include("pinned.jl")
include("mates.jl")

println("Tests complete!")
toc()
