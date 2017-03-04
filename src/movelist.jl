# movelist.jl

const MAX_MOVES_PER_TURN = 100
const MAX_PLYS_CAN_LOOK = 100

# TODO: create my own iteration structure to make the transition easier
type Movelist
    # TODO: make this a solid matrix, not a ragged list, for efficiency
    moves::Array{Array{Move, 1}, 1}  # (MAX_PLYS_CAN_LOOK x MAX_MOVES_PER_TURN)
    ply_n::Int8                      # index i into moves
    ply_move_index::Array{Int8, 1}   # ith index j into moves

    attacking_moves::Array{Move, 1}
    attacked_squares::Array{UInt64, 1}
    attack_move_n::UInt8   # index i into attacking moves / squares
end

function Movelist()
    ply_move_index = zeros(UInt8, MAX_PLYS_CAN_LOOK)
    ply_move_index[1] = 1
    moves = Array{Move, 1}[]
    for i in 1:MAX_PLYS_CAN_LOOK
        push!(moves, Array(Move, MAX_MOVES_PER_TURN))
        for j in 1:MAX_MOVES_PER_TURN
            moves[i][j] = Move(NONE, NONE, UInt64(0), UInt64(0))
        end
    end
    ply_n = UInt8(1)
    attacking_moves = Array(Move, MAX_MOVES_PER_TURN)
    for j in 1:MAX_MOVES_PER_TURN
        attacking_moves[j] = Move(NONE, NONE, UInt64(0), UInt64(0))
    end
    attacked_squares = zeros(UInt64, MAX_MOVES_PER_TURN)
    attack_move_n = UInt8(1)
    Movelist(moves, ply_n, ply_move_index, attacking_moves, attacked_squares, attack_move_n)
end



function Base.show(io::IO, ml::Movelist)
    print(io, "\n")

    print(io, "MAX_MOVES_PER_TURN $MAX_MOVES_PER_TURN\n")
    print(io, "MAX_PLYS_CAN_LOOK  $MAX_PLYS_CAN_LOOK\n")
    print(io, "\n")

    print(io, "ply_n $(ml.ply_n) \n")
    print(io, "ply_move_index $(ml.ply_move_index) \n")
    print(io, "\n")

    #print(io, "moves[] []\n")
    for j in 1:MAX_PLYS_CAN_LOOK
        print(io, "$(ml.moves[j]) \n")
    end

    print(io, "\n")

    print(io, "attacking_moves $(ml.attacking_moves) \n")
    print(io, "attacked_squares $(square_name(ml.attacked_squares)) \n")
    print(io, "attack_move_n $(ml.attack_move_n) \n")

    print(io, "\n")

end



# TODO: inline these for efficiency
function number_of_moves(ml::Movelist)
    nmoves = ml.ply_move_index[ml.ply_n] - 1
end

function increment_move_count(ml::Movelist)
    ml.ply_move_index[ml.ply_n] += 1
end
function increment_ply_count(ml::Movelist)
    ml.ply_n += 1

    # reset move count
    ml.ply_move_index[ml.ply_n] = 1
    ml.attack_move_n = 1
end
function decrement_ply_count(ml::Movelist)
    # reset move count
    ml.ply_move_index[ml.ply_n] = 1
    ml.attack_move_n = 1

    ml.ply_n -= 1

    @assert ml.ply_n > 0
end

function reset_movelist(ml::Movelist)
    ml.ply_move_index = zeros(UInt8, MAX_PLYS_CAN_LOOK)
    ml.moves = Array{Move, 1}[]
    for i in 1:MAX_PLYS_CAN_LOOK
        push!(ml.moves, Array(Move, MAX_MOVES_PER_TURN))
        for j in 1:MAX_MOVES_PER_TURN
            ml.moves[i][j] = Move(NONE, NONE, UInt64(0), UInt64(0))
        end
    end
    ml.ply_n = UInt8(1)
    ml.attacking_moves = Array(Move, MAX_MOVES_PER_TURN)
    for j in 1:MAX_MOVES_PER_TURN
        ml.attacking_moves[j] = Move(NONE, NONE, UInt64(0), UInt64(0))
    end
    ml.attacked_squares = zeros(UInt64, MAX_MOVES_PER_TURN)
    ml.attack_move_n = UInt8(1)
end

function get_move(ml::Movelist)
    # purely for debugging, show the
    if ml.ply_move_index[ml.ply_n] > length(ml.moves[ml.ply_n]) ||
        ml.ply_move_index[ml.ply_n] < 1
        @show ml.ply_n
        @show ml.ply_move_index
        @show length(ml.moves[ml.ply_n])
        println()
        @show ml
    end

    move = ml.moves[ml.ply_n][ml.ply_move_index[ml.ply_n]]
end
function get_attacking_move(ml::Movelist)
    move = ml.attacking_moves[ml.attack_move_n]
end
function increment_attacking_move_count(ml::Movelist)
    ml.attack_move_n += 1
end

function get_list_of_moves(ml::Movelist)
    ml.moves[ml.ply_n]
end

# TODO: make illegal_moves type specified for clarity   illegal_moves::Array{Move,1}
function filter_illegal_moves_out!(ml::Movelist, illegal_moves)
    if length(illegal_moves) == 0
        return
    end

    #@show ml
    @show illegal_moves

    i = 1
    while i <= MAX_MOVES_PER_TURN
        if ml.moves[ml.ply_n][i] ∈ illegal_moves
            # copy all moves above this move down one slot
            for j in i+1:MAX_MOVES_PER_TURN
                ml.moves[ml.ply_n][j-1] = ml.moves[ml.ply_n][j]
            end
            ml.ply_move_index[ml.ply_n] -= 1
            @assert ml.ply_move_index[ml.ply_n] > 0
        end
        i = i + 1
    end
end

function sort_moves_by_captures!(ml::Movelist)
    sort!(ml.moves[ml.ply_n], by=move->move.piece_taken, rev=true)
end

function record_attacked_squares(ml::Movelist)
    for i in 1:ml.attack_move_n
        ml.attacked_squares[i] = ml.attacking_moves[i].sqr_dest
    end
end

function clear_attacked_squares!(ml::Movelist)
    fill!(ml.attacked_squares, UInt64(0))
end

function is_square_attacked(ml::Movelist, test_square)
    test_square_attacked = test_square ∈ ml.attacked_squares
end
