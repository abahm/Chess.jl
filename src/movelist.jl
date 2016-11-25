# movelist.jl

const MAX_MOVES_PER_TURN = 100
const MAX_PLYS_CAN_LOOK = 100

type Movelist
    moves::Array{Array{Move, 1}, 1}  # (MAX_MOVES_PER_TURN x MAX_PLYS_CAN_LOOK)
    move_n::UInt8          # index i into moves
    ply_n::UInt8           # index j into moves

    attacking_moves::Array{Move, 1}
    attacked_squares::Array{UInt64, 1}
    attack_move_n::UInt8   # index i into attacking moves / squares
end

function Movelist()
    moves = Array{Move, 1}[]
    for i in 1:MAX_PLYS_CAN_LOOK
        push!(moves, Array(Move, MAX_MOVES_PER_TURN))
        for j in 1:MAX_MOVES_PER_TURN
            moves[i][j] = Move(NONE, NONE, UInt64(0), UInt64(0))
        end
    end
    move_n = UInt8(1)
    ply_n = UInt8(1)
    attacking_moves = Array(Move, MAX_MOVES_PER_TURN)
    for j in 1:MAX_MOVES_PER_TURN
        attacking_moves[j] = Move(NONE, NONE, UInt64(0), UInt64(0))
    end
    attacked_squares = zeros(UInt64, MAX_MOVES_PER_TURN)
    attack_move_n = UInt8(1)
    Movelist(moves, move_n, ply_n, attacking_moves, attacked_squares, attack_move_n)
end
