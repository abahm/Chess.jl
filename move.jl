# move.jl


# allows for move
type Move
    color_moving::UInt8
    piece_moving::UInt8
    sqr_src::UInt64
    sqr_dest::UInt64
    piece_taken::UInt8
    castling::UInt8
    sqr_ep::UInt64
    promotion_to::UInt8

    #details::UInt64  # could compress this
    # move_type
    #   bits 0-2 : type of piece moving
    #   bits 3-5 : type of piece captured
    #   bits 6-8 : type of piece promotion
    #   bits 9-10: castling
end

Move(color::UInt8, piece_moving::UInt8, src::UInt64, dest::UInt64; piece_taken::UInt8=UInt8(0), castling::UInt8=UInt8(0), sqr_ep::UInt64=UInt64(0), promotion_to::UInt8=UInt8(0)) = Move(color, piece_moving, src, dest, piece_taken, castling, sqr_ep, promotion_to)


function Base.show(io::IO, move::Move)
    print(io, algebraic_move(move))
end


# for UCI interface
function long_algebraic_move(m::Move)
    uci_move = square_name(m.sqr_src)
    uci_move *= square_name(m.sqr_dest)
    if m.promotion_to==QUEEN   uci_move *= "q"  end
    if m.promotion_to==KNIGHT  uci_move *= "n"  end
    if m.promotion_to==BISHOP  uci_move *= "b"  end
    if m.promotion_to==ROOK    uci_move *= "r"  end
    uci_move
end

function algebraic_move(m::Move)
    if m.castling & CASTLING_RIGHTS_WHITE_KINGSIDE > 0 ||
       m.castling & CASTLING_RIGHTS_BLACK_KINGSIDE > 0
        return "⚬-⚬" #"○-○" #"o-o"
    end

    if m.castling & CASTLING_RIGHTS_WHITE_QUEENSIDE > 0 ||
       m.castling & CASTLING_RIGHTS_BLACK_QUEENSIDE > 0
        return "⚬-⚬-⚬" #"○-○-○" #"o-o-o"
    end

    piece_character = character_for_piece(m.color_moving, m.piece_moving)

    sqr_name = square_name(m.sqr_dest)

    optionally_promoted_to = ""
    if m.promotion_to!=NONE
        optionally_promoted_to = "($(character_for_piece(m.color_moving, m.promotion_to)) )"
    end

    "$piece_character $sqr_name$optionally_promoted_to"
end

function print_algebraic(m::Move)
    println(algebraic_move(m) * " ")
end

function print_algebraic(moves::Array{Move,1})
    for (i,m) in enumerate(moves)
        print(algebraic_move(m) * " ")
        if i%10==0
            println()
        end
    end
    println()
end
