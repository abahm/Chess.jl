# runtests.jl

# put Chess.jl in your load path (for this session only)
#chess_dir = pwd()*"/.."
#@show chess_dir
#if chess_dir∉LOAD_PATH  push!(LOAD_PATH, chess_dir)  end

# load the Chess.jl module for testing
using Chess
using Base.Test

tic()

function print_algebraic(m::Move)
    println(algebraic_format(m) * " ")
end

function print_algebraic(moves::Array{Move,1})
    for (i,m) in enumerate(moves)
        print(algebraic_format(m) * " ")
        if i%10==0
            println()
        end
    end
    println()
end



include("mates.jl")
include("undo_move.jl")
include("generate_moves.jl")
include("pinned.jl")

println("Tests complete!")
toc()
