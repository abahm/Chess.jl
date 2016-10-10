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
    white_castled::Bool
    black_castled::Bool
end

import Base.deepcopy
Base.deepcopy(b::Board) = Board(b.white_pieces, b.black_pieces,
                                b.kings, b.queens, b.rooks,
                                b.bishops, b.knights, b.pawns,
                                b.white_castled, b.black_castled)

NONE = 0
KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN = 1,2,3,4,5,6
WHITE, BLACK = 1,2
A,B,C,D,E,F,G,H = 1,2,3,4,5,6,7,8


function square(c, r)
    sqr = UInt64(1) << ((c-1) + 8*(r-1))
    sqr
end

function set!(b::Board, clr, p, c, r)
    #@show clr, p, r, c
    mask = square(c, r)
    #@show bin(mask, 64)
    if p==KING    b.kings|=mask    end
    if p==QUEEN   b.queens|=mask   end
    if p==ROOK    b.rooks|=mask    end
    if p==BISHOP  b.bishops|=mask  end
    if p==KNIGHT  b.knights|=mask  end
    if p==PAWN    b.pawns|=mask    end
    if clr==WHITE  b.white_pieces|=mask   end
    if clr==BLACK  b.black_pieces|=mask   end
    nothing
end

function new_game()
    b = Board(0,0,0,0,0,0,0,0,true,true)

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

function piece_on_sqr(b::Board, sqr::UInt64)
    if (b.kings   & sqr)>0  return KING  end
    if (b.queens  & sqr)>0  return QUEEN  end
    if (b.rooks   & sqr)>0  return ROOK  end
    if (b.bishops & sqr)>0  return BISHOP  end
    if (b.knights & sqr)>0  return KNIGHT  end
    if (b.pawns   & sqr)>0  return PAWN  end
    return NONE
end

function color_on_sqr(b::Board, sqr::UInt64)
    if (b.white_pieces & sqr)>0  return WHITE  end
    if (b.black_pieces & sqr)>0  return BLACK  end
    return NONE
end

CHARACTER_KING, CHARACTER_QUEEN, CHARACTER_ROOK, CHARACTER_BISHOP, CHARACTER_KNIGHT, CHARACTER_PAWN = 'k','q','r','b','n','p'
CHARACTER_KING, CHARACTER_QUEEN, CHARACTER_ROOK, CHARACTER_BISHOP, CHARACTER_KNIGHT, CHARACTER_PAWN = '♔','♕','♖','♗','♘','♙'
function character_sqr_piece(b::Board, sqr::UInt64)
    s = CHARACTER_SQUARE_EMPTY
    p = piece_on_sqr(b, sqr)
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
function printbd(b::Board, moves=nothing)
    for r in 8:-1:1
        print("  ")
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
            print("$s ")
        end
        println("")
    end
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

UNBLOCKED, BLOCKED = 0,1
# a move could be a Board that is XORed with a current Board
function add_move!(moves, b::Board, src_sqr, dest_sqr, my_color, en_passant_sqr=UInt64(0), promotion_to=NONE)
    if dest_sqr==0
        return BLOCKED
    end

    #@show bin(dest_sqr)
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
function generate_moves(b::Board, white_to_move::Bool, last_move_pawn_double_push::UInt64=UInt64(0))
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

            # castling
        end

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
            if my_color==BLACK
                ONE_SQUARE_FORWARD *= -1
                TWO_SQUARE_FORWARD *= -1
                TAKE_LEFT *= -1
                TAKE_RIGHT *= -1
                START_ROW = 7
                LAST_ROW = 2
            end

            new_sqr = sqr << ONE_SQUARE_FORWARD
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
                    new_sqr = sqr << TWO_SQUARE_FORWARD
                    if occupied_by(b, new_sqr) == NONE
                        add_move!(moves, b, sqr, new_sqr, my_color)
                    end
                end
            end
            new_sqr = (sqr << TAKE_LEFT) & ~FILE_H
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
            new_sqr = (sqr << TAKE_RIGHT) & ~FILE_A
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
            if last_move_pawn_double_push > 0
                new_sqr = last_move_pawn_double_push << ONE_SQUARE_FORWARD
                add_move!(moves, b, sqr, new_sqr, my_color, last_move_pawn_double_push)
            end
        end
    end # for square_index in 1:64

    # TODO add add castling

    moves
end

function draw_with_fonts()
    # convert -size 360x360 xc:white -font "FreeMono" -pointsize 12 -fill black -draw @ascii.txt image.png

    # use alpha2 chess diagram font
end
