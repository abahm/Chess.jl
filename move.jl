# move.jl


# allows for move and unmove
type Move
    sqr_src::UInt64
    sqr_dest::UInt64
    sqr_ep::UInt64
    promotion_to::Integer
    castling::UInt8
end
Move(src, dest) = Move(src, dest, UInt64(0), NONE, UInt8(0))
Move(src, dest, cstl) = Move(src, dest, UInt64(0), NONE, cstl)
Move(src, dest, ep, promote) = Move(src, dest, ep, promote, UInt8(0))

function square_name(sqr::UInt64)
    file_character = ' '
    if sqr & FILE_A > 0  file_character = 'a'  end
    if sqr & FILE_B > 0  file_character = 'b'  end
    if sqr & FILE_C > 0  file_character = 'c'  end
    if sqr & FILE_D > 0  file_character = 'd'  end
    if sqr & FILE_E > 0  file_character = 'e'  end
    if sqr & FILE_F > 0  file_character = 'f'  end
    if sqr & FILE_G > 0  file_character = 'g'  end
    if sqr & FILE_H > 0  file_character = 'h'  end
    rank_character = ' '
    if sqr & RANK_1 > 0  rank_character = '1'  end
    if sqr & RANK_2 > 0  rank_character = '2'  end
    if sqr & RANK_3 > 0  rank_character = '3'  end
    if sqr & RANK_4 > 0  rank_character = '4'  end
    if sqr & RANK_5 > 0  rank_character = '5'  end
    if sqr & RANK_6 > 0  rank_character = '6'  end
    if sqr & RANK_7 > 0  rank_character = '7'  end
    if sqr & RANK_8 > 0  rank_character = '8'  end
    "$file_character$rank_character"
end

function algebraic_move(m::Move, b::Board)
    if m.castling & CASTLING_RIGHTS_WHITE_KINGSIDE > 0 ||
       m.castling & CASTLING_RIGHTS_BLACK_KINGSIDE > 0
        return "⚬-⚬" #"○-○" #"o-o"
    end

    if m.castling & CASTLING_RIGHTS_WHITE_QUEENSIDE > 0 ||
       m.castling & CASTLING_RIGHTS_BLACK_QUEENSIDE > 0
        return "⚬-⚬-⚬" #"○-○-○" #"o-o-o"
    end

    piece_character = character_sqr_piece(b, m.sqr_src)
    if b.pawns & m.sqr_src > 0
        piece_character = ""
    end
    sqr_name = square_name(m.sqr_dest)
    optionally_promoted_to = ""
    if     m.promotion_to==QUEEN   optionally_promoted_to = "="*CHARACTER_QUEEN
    elseif m.promotion_to==KNIGHT  optionally_promoted_to = "="*CHARACTER_KNIGHT
    elseif m.promotion_to==ROOK    optionally_promoted_to = "="*CHARACTER_ROOK
    elseif m.promotion_to==BISHOP  optionally_promoted_to = "="*CHARACTER_BISHOP
    end

    "$piece_character $sqr_name$optionally_promoted_to"
end

function print_algebraic(m::Move, b::Board)
    println(algebraic_move(m, b) * " ")
end

function print_algebraic(moves::Array{Move,1}, b::Board)
    for (i,m) in enumerate(moves)
        print(algebraic_move(m, b) * " ")
        if i%10==0
            println()
        end
    end
    println()
end
