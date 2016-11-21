# movelist.jl

const MAX_MOVES_PER_TURN = 100
const MAX_PLYS_CAN_LOOK = 100

type Movelist
    moves::Array{Array{Move, 1}, 1}  # (MAX_MOVES_PER_TURN x MAX_PLYS_CAN_LOOK)
    move_n::UInt8          # index i into moves
    ply_n::UInt8           # index j into moves

    attacking_moves::Array{Move,1}
end

function Movelist()
    moves = Array{Move, 1}[]
    for i in 1:MAX_PLYS_CAN_LOOK
        push!(moves, Array(Move, MAX_MOVES_PER_TURN))
    end
    Movelist(moves, UInt8(1), UInt8(1), Array(Move, MAX_MOVES_PER_TURN))
end
