# runtests.jl

# put Chess.jl in your load path (for this session only)
#chess_dir = pwd()*"/.."
#@show chess_dir
#if chess_dir∉LOAD_PATH  push!(LOAD_PATH, chess_dir)  end

# load the Chess.jl module for testing
using Chess
using Test

time_start_ns = time_ns()

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

include("generate_moves.jl")
include("undo_move.jl")
include("pinned.jl")
include("search.jl")
include("mates.jl")

println("Tests complete!")
time_s = (time_ns() - time_start_ns)*1e-9
println("$time_s seconds")
