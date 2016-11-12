# movelist.jl

const MAX_MOVES_PER_TURN = 100
const MAX_PLYS_CAN_LOOK = 100

type Movelist
    moves::Array{Move, 2}  # (MAX_MOVES_PER_TURN x MAX_PLYS_CAN_LOOK)
    move_n::UInt8
    ply_n::UInt8

    attacking_moves::Array{Move,1}
end
