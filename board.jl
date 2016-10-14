# board.jl


# take the intersection of white_pieces with queens to find white's queen...
type Board   # known as "dense Board representation"
    white_pieces::UInt64
    black_pieces::UInt64
    kings::UInt64
    queens::UInt64
    rooks::UInt64
    bishops::UInt64
    knights::UInt64
    pawns::UInt64
    castling_rights::UInt8
    last_move_pawn_double_push::UInt64
end
Board() = Board(0,0, 0,0,0, 0,0,0, 0x0F,0)

import Base.deepcopy
Base.deepcopy(b::Board) = Board(b.white_pieces, b.black_pieces,
                                b.kings, b.queens, b.rooks,
                                b.bishops, b.knights, b.pawns,
                                b.castling_rights,
                                b.last_move_pawn_double_push)

function Base.show(io::IO, b::Board)
    print(io, "\n")
    printbd(b, io)

    print(io, "\n")
    print(io, "white pieces\n")
    for r in 8:-1:1
        for c in 1:8
            sqr = square(c,r)
            print(io, "$((b.white_pieces & sqr)>0?1:0) ")
        end
        print(io, "\n")
    end
    print(io, "\n")

    print(io, "black pieces\n")
    for r in 8:-1:1
        for c in 1:8
            sqr = square(c,r)
            print(io, "$((b.black_pieces & sqr)>0?1:0) ")
        end
        print(io, "\n")
    end
    print(io, "\n")

    print(io, "kings\n")
    for r in 8:-1:1
        for c in 1:8
            sqr = square(c,r)
            print(io, "$((b.kings & sqr)>0?1:0) ")
        end
        print(io, "\n")
    end
    print(io, "\n")

    print(io, "queens\n")
    for r in 8:-1:1
        for c in 1:8
            sqr = square(c,r)
            print(io, "$((b.queens & sqr)>0?1:0) ")
        end
        print(io, "\n")
    end
    print(io, "\n")


    print(io, "rooks\n")
    for r in 8:-1:1
        for c in 1:8
            sqr = square(c,r)
            print(io, "$((b.rooks & sqr)>0?1:0) ")
        end
        print(io, "\n")
    end
    print(io, "\n")

    print(io, "bishops\n")
    for r in 8:-1:1
        for c in 1:8
            sqr = square(c,r)
            print(io, "$((b.bishops & sqr)>0?1:0) ")
        end
        print(io, "\n")
    end
    print(io, "\n")

    print(io, "knights\n")
    for r in 8:-1:1
        for c in 1:8
            sqr = square(c,r)
            print(io, "$((b.knights & sqr)>0?1:0) ")
        end
        print(io, "\n")
    end
    print(io, "\n")

    print(io, "pawns\n")
    for r in 8:-1:1
        for c in 1:8
            sqr = square(c,r)
            print(io, "$((b.pawns & sqr)>0?1:0) ")
        end
        print(io, "\n")
    end
    print(io, "\n")
end

NONE = 0
KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN = 1,2,3,4,5,6
WHITE, BLACK = 1,2
A,B,C,D,E,F,G,H = 1,2,3,4,5,6,7,8

CASTLING_RIGHTS_WHITE_KINGSIDE = UInt8(1)
CASTLING_RIGHTS_WHITE_QUEENSIDE = CASTLING_RIGHTS_WHITE_KINGSIDE << 1
CASTLING_RIGHTS_BLACK_KINGSIDE = CASTLING_RIGHTS_WHITE_KINGSIDE << 2
CASTLING_RIGHTS_BLACK_QUEENSIDE = CASTLING_RIGHTS_WHITE_KINGSIDE << 3
CASTLING_RIGHTS_WHITE_ANYSIDE = CASTLING_RIGHTS_WHITE_KINGSIDE | CASTLING_RIGHTS_WHITE_QUEENSIDE
CASTLING_RIGHTS_BLACK_ANYSIDE = CASTLING_RIGHTS_BLACK_KINGSIDE | CASTLING_RIGHTS_BLACK_QUEENSIDE

function set!(b::Board, color, p, c, r)
    #@show color, p, r, c
    mask = square(c, r)
    #@show bin(mask, 64)
    if p==KING    b.kings|=mask    end
    if p==QUEEN   b.queens|=mask   end
    if p==ROOK    b.rooks|=mask    end
    if p==BISHOP  b.bishops|=mask  end
    if p==KNIGHT  b.knights|=mask  end
    if p==PAWN    b.pawns|=mask    end
    if color==WHITE  b.white_pieces|=mask   end
    if color==BLACK  b.black_pieces|=mask   end
    nothing
end

function new_game()
    b = Board()

    set!(b, WHITE, ROOK,   A, 1)
    set!(b, WHITE, KNIGHT, B, 1)
    set!(b, WHITE, BISHOP, C, 1)
    set!(b, WHITE, QUEEN,  D, 1)
    set!(b, WHITE, KING,   E, 1)
    set!(b, WHITE, BISHOP, F, 1)
    set!(b, WHITE, KNIGHT, G, 1)
    set!(b, WHITE, ROOK,   H, 1)

    set!(b, WHITE, PAWN, A, 2)
    set!(b, WHITE, PAWN, B, 2)
    set!(b, WHITE, PAWN, C, 2)
    set!(b, WHITE, PAWN, D, 2)
    set!(b, WHITE, PAWN, E, 2)
    set!(b, WHITE, PAWN, F, 2)
    set!(b, WHITE, PAWN, G, 2)
    set!(b, WHITE, PAWN, H, 2)

    set!(b, BLACK, PAWN, A, 7)
    set!(b, BLACK, PAWN, B, 7)
    set!(b, BLACK, PAWN, C, 7)
    set!(b, BLACK, PAWN, D, 7)
    set!(b, BLACK, PAWN, E, 7)
    set!(b, BLACK, PAWN, F, 7)
    set!(b, BLACK, PAWN, G, 7)
    set!(b, BLACK, PAWN, H, 7)

    set!(b, BLACK, ROOK,   A, 8)
    set!(b, BLACK, KNIGHT, B, 8)
    set!(b, BLACK, BISHOP, C, 8)
    set!(b, BLACK, QUEEN,  D, 8)
    set!(b, BLACK, KING,   E, 8)
    set!(b, BLACK, BISHOP, F, 8)
    set!(b, BLACK, KNIGHT, G, 8)
    set!(b, BLACK, ROOK,   H, 8)

    #@show b
    b
end

function piece_type_on_sqr(b::Board, sqr::UInt64)
    if (b.kings   & sqr)>0  return KING  end
    if (b.queens  & sqr)>0  return QUEEN  end
    if (b.rooks   & sqr)>0  return ROOK  end
    if (b.bishops & sqr)>0  return BISHOP  end
    if (b.knights & sqr)>0  return KNIGHT  end
    if (b.pawns   & sqr)>0  return PAWN  end
    return NONE
end

function piece_color_on_sqr(b::Board, sqr::UInt64)
    if (b.white_pieces & sqr)>0  return WHITE  end
    if (b.black_pieces & sqr)>0  return BLACK  end
    return NONE
end

CHARACTER_KING, CHARACTER_QUEEN, CHARACTER_ROOK, CHARACTER_BISHOP, CHARACTER_KNIGHT, CHARACTER_PAWN = 'k','q','r','b','n','p'
CHARACTER_KING, CHARACTER_QUEEN, CHARACTER_ROOK, CHARACTER_BISHOP, CHARACTER_KNIGHT, CHARACTER_PAWN = '♔','♕','♖','♗','♘','♙'
function character_sqr_piece(b::Board, sqr::UInt64)
    s = CHARACTER_SQUARE_EMPTY
    p = piece_type_on_sqr(b, sqr)
    if     p == KING    s = CHARACTER_KING
    elseif p == QUEEN   s = CHARACTER_QUEEN
    elseif p == ROOK    s = CHARACTER_ROOK
    elseif p == BISHOP  s = CHARACTER_BISHOP
    elseif p == KNIGHT  s = CHARACTER_KNIGHT
    elseif p == PAWN    s = CHARACTER_PAWN
    end

    if (b.white_pieces & sqr)>0
        s = s + 6
    end
    s
end

CHARACTER_SQUARE_EMPTY, CHARACTER_SQUARE_ATTACKED, CHARACTER_SQUARE_CAPTURE = '⋅', '•', 'x'  #'∘'
CHARACTER_SQUARE_EMPTY = '–'
CHARACTER_SQUARE_EMPTY = '⋯'
CHARACTER_SQUARE_EMPTY = '_'
CHARACTER_SQUARE_EMPTY = '.'
#CHARACTER_SQUARE_EMPTY = ' '
#CHARACTER_SQUARE_EMPTY = '▓'

#SMALL_NUMBERS = ['𝟣','𝟤','𝟥','𝟦','𝟧','𝟨','𝟩','𝟪']
SMALL_NUMBERS = ['₁','₂','₃','₄','₅','₆','₇','₈']
function printbd(b::Board, io=STDOUT, moves=nothing)
    print(io, "    ")
    print(io, (b.castling_rights & CASTLING_RIGHTS_BLACK_QUEENSIDE) > 0 )
    print(io, "       ")
    print(io, (b.castling_rights & CASTLING_RIGHTS_BLACK_KINGSIDE) > 0 )
    if b.last_move_pawn_double_push > 0
        print(io, "   en passant from $(square_name(b.last_move_pawn_double_push))")
    end
    print(io, "\n")

    for r in 8:-1:1
        print(io, "$(SMALL_NUMBERS[r])   ")
        for c in 1:8
            sqr = square(c, r)
            s = character_sqr_piece(b,sqr)
            if moves!=nothing
                for m in moves
                    if (m.sqr_dest & sqr)>0
                        if s != CHARACTER_SQUARE_EMPTY && s != CHARACTER_SQUARE_ATTACKED
                            s = CHARACTER_SQUARE_CAPTURE
                        else
                            s = CHARACTER_SQUARE_ATTACKED
                        end
                    end
                end
            end
            print(io, "$s ")
        end
        print(io, "\n")
    end
    print(io, "    ")
    print(io, (b.castling_rights & CASTLING_RIGHTS_WHITE_QUEENSIDE) > 0 )
    print(io, "       ")
    print(io, (b.castling_rights & CASTLING_RIGHTS_WHITE_KINGSIDE) > 0 )
    print(io, "\n")
    print(io, b.castling_rights)
    print(io, "\n")
    #println("    a b c d e f g h")
    #println("    ᵃ ᵇ ᶜ ᵈ ᵉ ᶠ ᵍ ᴴ")
    #println("    𝑎 𝑏 𝑐 𝑑 𝑒 𝑓 𝑔 h")
    #println("    𝔞 𝔟 𝔠 𝔡 𝔢 𝔣 𝔤 𝔥")
    #println("    𝖠 𝖡 𝖢 𝖣 𝖤 𝖥 𝖦 𝖧")
    #println("    𝕒 𝕓 𝕔 𝕕 𝕖 𝕗 𝕘 𝕙")
    print(io, "    𝖺 𝖻 𝖼 𝖽 𝖾 𝖿 𝗀 𝗁\n")
end

function debug_print(b::Board)
    for r in 8:-1:1
        print("$(SMALL_NUMBERS[r])   ")
        for c in 1:8
            sqr = square(c, r)
            s = character_sqr_piece(b,sqr)
            print("$s ")
        end
        println()
    end
    println()
    println("    𝖺 𝖻 𝖼 𝖽 𝖾 𝖿 𝗀 𝗁")
end

function occupied_by(b::Board, sqr::UInt64)

    if b.white_pieces & sqr > 0
        return WHITE
    end

    if b.black_pieces & sqr > 0
        return BLACK
    end

    return NONE
end

# handle adding sliding moves of QUEEN, ROOK, BISHOP
#  which end by being BLOCKED or capturing an enemy piece
UNBLOCKED, BLOCKED = 0,1
function add_move!(moves, b::Board, src_sqr::UInt64, dest_sqr::UInt64, my_color, en_passant_sqr=UInt64(0), promotion_to=NONE)
    #@show src_sqr, dest_sqr, my_color, en_passant_sqr, promotion_to
    if dest_sqr==0
        return BLOCKED
    end

    o = occupied_by(b,dest_sqr)

    if o==my_color
        return BLOCKED
    end

    if o!=NONE
        push!(moves, Move(src_sqr, dest_sqr))
        return BLOCKED
    end

    push!(moves, Move(src_sqr, dest_sqr, en_passant_sqr, promotion_to) )

    return UNBLOCKED
end

FILE_A = 0x0101010101010101
FILE_B = FILE_A << 1
FILE_C = FILE_A << 2
FILE_D = FILE_A << 3
FILE_E = FILE_A << 4
FILE_F = FILE_A << 5
FILE_G = FILE_A << 6
FILE_H = FILE_A << 7
RANK_1 = 0x00000000000000FF
RANK_2 = RANK_1 << (8*1)
RANK_3 = RANK_1 << (8*2)
RANK_4 = RANK_1 << (8*3)
RANK_5 = RANK_1 << (8*4)
RANK_6 = RANK_1 << (8*5)
RANK_7 = RANK_1 << (8*6)
RANK_8 = RANK_1 << (8*7)
FILE_AB = FILE_A | FILE_B
FILE_GH = FILE_G | FILE_H

SQUARE_A1 = 0x0000000000000001
SQUARE_B1 = SQUARE_A1 << 1
SQUARE_C1 = SQUARE_A1 << 2
SQUARE_D1 = SQUARE_A1 << 3
SQUARE_E1 = SQUARE_A1 << 4
SQUARE_F1 = SQUARE_A1 << 5
SQUARE_G1 = SQUARE_A1 << 6
SQUARE_H1 = SQUARE_A1 << 7

SQUARE_A8 = SQUARE_A1 << 56
SQUARE_B8 = SQUARE_A1 << 57
SQUARE_C8 = SQUARE_A1 << 58
SQUARE_D8 = SQUARE_A1 << 59
SQUARE_E8 = SQUARE_A1 << 60
SQUARE_F8 = SQUARE_A1 << 61
SQUARE_G8 = SQUARE_A1 << 62
SQUARE_H8 = SQUARE_A1 << 63

function draw_with_fonts()
    # convert -size 360x360 xc:white -font "FreeMono" -pointsize 12 -fill black -draw @ascii.txt image.png
    # use alpha2 chess diagram font
end

function board_validation_checks(b::Board)
    # check no overlap - each square can have one and only one piece

    for i in 0:63
        sqr = UInt64(1) << i

        # a color must have a piece
        if sqr & b.white_pieces > 0
            @assert (sqr & (b.pawns | b.knights | b.bishops | b.rooks | b.queens | b.kings) > 0) "$b\n white nothing at $(square_name(sqr))"
        end
        if sqr & b.black_pieces > 0
            @assert (sqr & (b.pawns | b.knights | b.bishops | b.rooks | b.queens | b.kings) > 0) "$b\n black nothing at $(square_name(sqr))"
        end

        # square can't hold both a black and a white piece simultaneously
        @assert sqr & b.white_pieces & b.black_pieces == 0  "$b\n over occupied at $(square_name(sqr))"

        # a piece must have a color
        if sqr & b.pawns > 0
            @assert (sqr & b.pawns & b.white_pieces > 0) || (sqr & b.pawns & b.black_pieces > 0) "$b\n colorless pawn at $(square_name(sqr))"
        end
        if sqr & b.knights > 0
            @assert (sqr & b.knights & b.white_pieces > 0) || (sqr & b.knights & b.black_pieces > 0) "$b\n colorless knight at $(square_name(sqr))"
        end
        if sqr & b.bishops > 0
            @assert (sqr & b.bishops & b.white_pieces > 0) || (sqr & b.bishops & b.black_pieces > 0) "$b\n colorless bishop at $(square_name(sqr))"
        end
        if sqr & b.rooks > 0
            @assert (sqr & b.rooks & b.white_pieces > 0) || (sqr & b.rooks & b.black_pieces > 0) "$b\n colorless rook at $(square_name(sqr))"
        end
        if sqr & b.queens > 0
            @assert (sqr & b.queens & b.white_pieces > 0) || (sqr & b.queens & b.black_pieces > 0) "$b\n colorless queen at $(square_name(sqr))"
        end
        if sqr & b.kings > 0
            @assert (sqr & b.kings & b.white_pieces > 0) || (sqr & b.kings & b.black_pieces > 0) "$b\n colorless king at $(square_name(sqr))"
        end
    end

    # s
    @assert b.kings & b.queens & b.rooks & b.bishops & b.knights & b.pawns == 0  "$b"

    # check counts
    n_white_pieces = count(i->i=='1', bits(b.white_pieces))
    n_black_pieces = count(i->i=='1', bits(b.black_pieces))

    n_kings = count(i->i=='1', bits(b.kings))
    n_queens = count(i->i=='1', bits(b.queens))
    n_rooks = count(i->i=='1', bits(b.rooks))
    n_bishops = count(i->i=='1', bits(b.bishops))
    n_knights = count(i->i=='1', bits(b.knights))
    n_pawns = count(i->i=='1', bits(b.pawns))

    t1 = n_white_pieces + n_black_pieces
    t2 = n_kings + n_queens + n_rooks + n_bishops + n_knights + n_pawns
    @assert t1==t2  "$b"
end

function generate_moves(b::Board, white_to_move::Bool, ignore_castling=false)
    my_color = white_to_move ? WHITE : BLACK
    enemy_color = white_to_move ? BLACK : WHITE
    moves = Move[]
    for square_index in 1:64
        sqr = UInt64(1) << (square_index-1)

        occupied = occupied_by(b,sqr)
        if occupied==NONE || occupied==enemy_color
            continue
        end

        # n.b. ÷ gives integer quotient like div()
        row = (square_index-1)÷8 + 1

        # kings moves
        king = sqr & b.kings
        if king > 0
            add_move!(moves, b, sqr, (sqr>>9) & ~FILE_H, my_color)
            add_move!(moves, b, sqr, (sqr>>8),           my_color)
            add_move!(moves, b, sqr, (sqr>>7) & ~FILE_A, my_color)
            add_move!(moves, b, sqr, (sqr>>1) & ~FILE_H, my_color)
            add_move!(moves, b, sqr, (sqr<<1) & ~FILE_A, my_color)
            add_move!(moves, b, sqr, (sqr<<7) & ~FILE_H, my_color)
            add_move!(moves, b, sqr, (sqr<<8),           my_color)
            add_move!(moves, b, sqr, (sqr<<9) & ~FILE_A, my_color)

            # castling kingside (allows for chess960 castling too)
            if !ignore_castling
                travel_sqrs = []
                if my_color == WHITE
                    # check for castling rights
                    if b.castling_rights & CASTLING_RIGHTS_WHITE_KINGSIDE > 0
                        travel_sqrs = [SQUARE_F1, SQUARE_G1]
                    end
                elseif my_color == BLACK
                    # check for castling rights
                    if b.castling_rights & CASTLING_RIGHTS_BLACK_KINGSIDE > 0
                        travel_sqrs = [SQUARE_F8, SQUARE_G8]
                    end
                end
                # check that the travel squares are empty
                if reduce(&, Bool[piece_type_on_sqr(b, s)==NONE for s in travel_sqrs])
                    blocked = false
                    # check that king's traversal squares are not attacked
                    attacking_moves = generate_moves(b, !white_to_move, true)
                    for m in attacking_moves
                        if m.sqr_dest in travel_sqrs
                            blocked = true
                            break
                        end
                    end
                    if !blocked && length(travel_sqrs)>0
                        push!(moves, Move(sqr, travel_sqrs[end], CASTLING_RIGHTS_WHITE_KINGSIDE) )
                    end
                end

                # castling queenside (allows for chess960 castling too)
                travel_sqrs = []
                if my_color == WHITE
                    # check for castling rights
                    if b.castling_rights & CASTLING_RIGHTS_WHITE_QUEENSIDE > 0
                        travel_sqrs = [SQUARE_D1, SQUARE_C1]
                    end
                elseif my_color == BLACK
                    # check for castling rights
                    if b.castling_rights & CASTLING_RIGHTS_BLACK_QUEENSIDE > 0
                        travel_sqrs = [SQUARE_D8, SQUARE_C8]
                    end
                end
                # check that the travel squares are empty
                if reduce(&, Bool[piece_type_on_sqr(b, s)==NONE for s in travel_sqrs])
                    blocked = false
                    # check that king's traversal squares are not attacked
                    attacking_moves = generate_moves(b, !white_to_move, true)
                    for m in attacking_moves
                        if m.sqr_dest in travel_sqrs
                            blocked = true
                            break
                        end
                    end
                    if !blocked && length(travel_sqrs)>0
                        push!(moves, Move(sqr, travel_sqrs[end], CASTLING_RIGHTS_WHITE_QUEENSIDE) )
                    end
                end
            end # castling checks
        end # king

        # rook moves
        queen = sqr & b.queens
        rook = sqr & b.rooks
        if rook > 0 || queen > 0
            for i in 1:7
                new_sqr = sqr>>i
                if new_sqr & FILE_H > 0
                    break
                end
                if add_move!(moves, b, sqr, new_sqr, my_color) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr<<i
                if new_sqr & FILE_A > 0
                    break
                end
                if add_move!(moves, b, sqr, new_sqr, my_color) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr>>(i*8)
                if add_move!(moves, b, sqr, new_sqr, my_color) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr<<(i*8)
                if add_move!(moves, b, sqr, new_sqr, my_color) == BLOCKED
                    break
                end
            end
        end

        # bishop moves
        bishop = sqr & b.bishops
        if bishop > 0 || queen > 0
            for i in 1:7
                new_sqr = sqr>>(i*9)
                if new_sqr & FILE_H > 0
                    break
                end
                if add_move!(moves, b, sqr, new_sqr, my_color) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr>>(i*7)
                if new_sqr & FILE_A > 0
                    break
                end
                if add_move!(moves, b, sqr, new_sqr, my_color) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr<<(i*7)
                if new_sqr & FILE_H > 0
                    break
                end
                if add_move!(moves, b, sqr, new_sqr, my_color) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr<<(i*9)
                if new_sqr & FILE_A > 0
                    break
                end
                if add_move!(moves, b, sqr, new_sqr, my_color) == BLOCKED
                    break
                end
            end
        end

        # knight moves
        knight = sqr & b.knights
        if knight > 0
            add_move!(moves, b, sqr, (sqr & ~FILE_A)>>17, my_color)
            add_move!(moves, b, sqr, (sqr & ~FILE_AB)>>10, my_color)
            add_move!(moves, b, sqr, (sqr & ~FILE_AB)<<6, my_color)
            add_move!(moves, b, sqr, (sqr & ~FILE_A)<<15, my_color)

            add_move!(moves, b, sqr, (sqr & ~FILE_H)>>15, my_color)
            add_move!(moves, b, sqr, (sqr & ~FILE_GH)<<10, my_color)
            add_move!(moves, b, sqr, (sqr & ~FILE_GH)>>6, my_color)
            add_move!(moves, b, sqr, (sqr & ~FILE_H)<<17, my_color)
        end

        # pawn moves
        pawn = sqr & b.pawns
        if pawn > 0
            ONE_SQUARE_FORWARD = 8
            TWO_SQUARE_FORWARD = 16
            TAKE_LEFT = 7
            TAKE_RIGHT = 9
            START_ROW = 2
            LAST_ROW = 7
            bitshift_direction = <<
            if my_color==BLACK
                TAKE_LEFT = 9
                TAKE_RIGHT = 7
                START_ROW = 7
                LAST_ROW = 2
                bitshift_direction = >>
            end
            new_sqr = bitshift_direction(sqr, ONE_SQUARE_FORWARD)
            if occupied_by(b, new_sqr) == NONE
                if row == LAST_ROW
                    add_move!(moves, b, sqr, new_sqr, my_color, 0, QUEEN)
                    add_move!(moves, b, sqr, new_sqr, my_color, 0, KNIGHT)
                    add_move!(moves, b, sqr, new_sqr, my_color, 0, ROOK)
                    add_move!(moves, b, sqr, new_sqr, my_color, 0, BISHOP)
                else
                    add_move!(moves, b, sqr, new_sqr, my_color)
                end
                if row == START_ROW
                    new_sqr = bitshift_direction(sqr, TWO_SQUARE_FORWARD)
                    if occupied_by(b, new_sqr) == NONE
                        add_move!(moves, b, sqr, new_sqr, my_color)
                    end
                end
            end
            new_sqr = bitshift_direction(sqr, TAKE_LEFT) & ~FILE_H
            if occupied_by(b, new_sqr) == enemy_color
                if row == LAST_ROW
                    add_move!(moves, b, sqr, new_sqr, my_color, 0, QUEEN)
                    add_move!(moves, b, sqr, new_sqr, my_color, 0, KNIGHT)
                    add_move!(moves, b, sqr, new_sqr, my_color, 0, ROOK)
                    add_move!(moves, b, sqr, new_sqr, my_color, 0, BISHOP)
                else
                    add_move!(moves, b, sqr, new_sqr, my_color)
                end
            end
            # en passant
            if b.last_move_pawn_double_push > 0 &&
                new_sqr == bitshift_direction(b.last_move_pawn_double_push, ONE_SQUARE_FORWARD)
                add_move!(moves, b, sqr, new_sqr, my_color, b.last_move_pawn_double_push)
            end
            new_sqr = bitshift_direction(sqr, TAKE_RIGHT) & ~FILE_A
            if occupied_by(b, new_sqr) == enemy_color
                if row == LAST_ROW
                    add_move!(moves, b, sqr, new_sqr, my_color, QUEEN)
                    add_move!(moves, b, sqr, new_sqr, my_color, KNIGHT)
                    add_move!(moves, b, sqr, new_sqr, my_color, ROOK)
                    add_move!(moves, b, sqr, new_sqr, my_color, BISHOP)
                else
                    add_move!(moves, b, sqr, new_sqr, my_color)
                end
            end
            # en passant
            if b.last_move_pawn_double_push > 0 &&
                new_sqr == bitshift_direction(b.last_move_pawn_double_push, ONE_SQUARE_FORWARD)
                add_move!(moves, b, sqr, new_sqr, my_color, b.last_move_pawn_double_push)
            end

        end
    end # for square_index in 1:64

    moves
end

function make_move!(b::Board, m::Move)
    #print_algebraic(m,b)
    #print(b)

    sqr_src = m.sqr_src
    sqr_dest = m.sqr_dest
    color = piece_color_on_sqr(b,sqr_src)
    moving_piece = piece_type_on_sqr(b,sqr_src)
    taken_piece = piece_type_on_sqr(b,sqr_dest)

    # remove any piece on destination square
    if taken_piece != NONE
        b.kings = b.kings & ~sqr_dest
        b.queens = b.queens & ~sqr_dest
        b.rooks = b.rooks & ~sqr_dest
        b.bishops = b.bishops & ~sqr_dest
        b.knights = b.knights & ~sqr_dest
        b.pawns = b.pawns & ~sqr_dest
        b.white_pieces = b.white_pieces & ~sqr_dest
        b.black_pieces = b.black_pieces & ~sqr_dest
    end

    # move the moving piece (remove from src, add to dest)
    if moving_piece == KING         b.kings = (b.kings & ~sqr_src) | sqr_dest
    elseif moving_piece == QUEEN    b.queens = (b.queens & ~sqr_src) | sqr_dest
    elseif moving_piece == ROOK     b.rooks = (b.rooks & ~sqr_src) | sqr_dest
    elseif moving_piece == BISHOP   b.bishops = (b.bishops & ~sqr_src) | sqr_dest
    elseif moving_piece == KNIGHT   b.knights = (b.knights & ~sqr_src) | sqr_dest
    elseif moving_piece == PAWN     b.pawns = (b.pawns & ~sqr_src) | sqr_dest
    end

    # set en passant marker
    b.last_move_pawn_double_push = UInt64(0)
    if moving_piece == PAWN &&
        (sqr_dest << 16 == sqr_src || sqr_src << 16 == sqr_dest)
        b.last_move_pawn_double_push = sqr_dest
    end

    # update the moving color (remove from src, add to dest)
    if (b.white_pieces & sqr_src) > 0
        b.white_pieces = (b.white_pieces & ~sqr_src) | sqr_dest
    end
    if (b.black_pieces & sqr_src) > 0
        b.black_pieces = (b.black_pieces & ~sqr_src) | sqr_dest
    end

    # en passant - remove any pawn taken by en passant
    if m.sqr_ep > 0
        b.pawns = b.pawns & ~m.sqr_ep
        b.white_pieces = b.white_pieces & ~m.sqr_ep
        b.black_pieces = b.black_pieces & ~m.sqr_ep
    end

    # pawn promotion
    if m.promotion_to > NONE
        b.pawns = b.pawns & ~sqr_dest
        if m.promotion_to == QUEEN       b.queens = b.queens | sqr_dest
        elseif m.promotion_to == KNIGHT  b.knights = b.knights | sqr_dest
        elseif m.promotion_to == ROOK    b.rooks = b.rooks | sqr_dest
        elseif m.promotion_to == BISHOP  b.bishops = b.bishops | sqr_dest
        end
    end

    # update castling rights
    if moving_piece == KING
        if color == WHITE      b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_WHITE_ANYSIDE
        elseif color == BLACK  b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_BLACK_ANYSIDE
        end
    elseif moving_piece == ROOK
        if sqr_src == SQUARE_A1       b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_WHITE_QUEENSIDE
        elseif sqr_src == SQUARE_H1   b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_WHITE_KINGSIDE
        elseif sqr_src == SQUARE_A8   b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_BLACK_QUEENSIDE
        elseif sqr_src == SQUARE_H8   b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_BLACK_KINGSIDE
        end
    end

    # castling - move rook in addition to the king
    if m.castling > 0
        @show m.castling
        if sqr_dest == SQUARE_C1
            b.rooks = (b.rooks & ~SQUARE_A1) | SQUARE_D1
            b.white_pieces = (b.white_pieces & ~SQUARE_A1)  | SQUARE_D1
        elseif sqr_dest == SQUARE_G1
            b.rooks = (b.rooks & ~SQUARE_H1) | SQUARE_F1
            b.white_pieces = (b.white_pieces & ~SQUARE_H1) | SQUARE_F1
        elseif sqr_dest == SQUARE_C8
            b.rooks = (b.rooks & ~SQUARE_A8) | SQUARE_D8
            b.black_pieces = (b.black_pieces & ~SQUARE_A8) | SQUARE_D8
        elseif sqr_dest == SQUARE_G8
            b.rooks = (b.rooks & ~SQUARE_H8) | SQUARE_F8
            b.black_pieces = (b.black_pieces & ~SQUARE_H8) | SQUARE_F8
        end
    end

    board_validation_checks(b)

    nothing
end
