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
    side_to_move::UInt8
    castling_rights::UInt8
    last_move_pawn_double_push::UInt64
end
Board() = Board(0,0, 0,0,0, 0,0,0, NONE, 0x0F,0)

import Base.deepcopy
Base.deepcopy(b::Board) = Board(b.white_pieces, b.black_pieces,
                                b.kings, b.queens, b.rooks,
                                b.bishops, b.knights, b.pawns,
                                b.side_to_move,
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

function clear_square(b::Board, c, r)
    sqr = square(c, r)
    b.white_pieces = b.white_pieces & ~sqr
    b.black_pieces = b.black_pieces & ~sqr
    b.kings = b.kings & ~sqr
    b.queens = b.queens & ~sqr
    b.rooks = b.rooks & ~sqr
    b.bishops = b.bishops & ~sqr
    b.knights = b.knights & ~sqr
    b.pawns = b.pawns & ~sqr
end

function set!(b::Board, color, p, c, r)
    clear_square(b, c, r) # insure all prior information is cleared out
    sqr = square(c, r)
    if p==KING    b.kings|=sqr    end
    if p==QUEEN   b.queens|=sqr   end
    if p==ROOK    b.rooks|=sqr    end
    if p==BISHOP  b.bishops|=sqr  end
    if p==KNIGHT  b.knights|=sqr  end
    if p==PAWN    b.pawns|=sqr    end
    if color==WHITE  b.white_pieces|=sqr   end
    if color==BLACK  b.black_pieces|=sqr   end
    nothing
end

function new_game()
    read_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
end



CHARACTER_SQUARE_ATTACKED = '•'
CHARACTER_SQUARE_CAPTURE = 'x'  #'∘'

CHARACTER_SQUARE_EMPTY = '⋅'
CHARACTER_SQUARE_EMPTY = '–'
CHARACTER_SQUARE_EMPTY = '⋯'
CHARACTER_SQUARE_EMPTY = '_'
CHARACTER_SQUARE_EMPTY = ' '
CHARACTER_SQUARE_EMPTY = '▓'
CHARACTER_SQUARE_EMPTY = '.'

CHARACTER_CASTLING_AVAILABLE = "↔"
CHARACTER_CASTLING_AVAILABLE = "⇋"
CHARACTER_CASTLING_AVAILABLE = "⟷"
CHARACTER_CASTLING_AVAILABLE = "⇔"

#SMALL_NUMBERS = ['𝟣','𝟤','𝟥','𝟦','𝟧','𝟨','𝟩','𝟪']
SMALL_NUMBERS = ['₁','₂','₃','₄','₅','₆','₇','₈']
function printbd(b::Board, io=STDOUT, moves=nothing)
    println("$(version)")
    println("FEN $(write_fen(b))")
    print(io, "       ")
    if b.castling_rights & CASTLING_RIGHTS_BLACK_QUEENSIDE > 0
        print(io, CHARACTER_CASTLING_AVAILABLE)
    end
    print(io, "       ")
    if b.castling_rights & CASTLING_RIGHTS_BLACK_KINGSIDE > 0
        print(io, CHARACTER_CASTLING_AVAILABLE)
    end
    if b.side_to_move==WHITE     print("      WHITE to move")
    elseif b.side_to_move==BLACK print("      BLACK to move")
    else                         print("      ????? to move")
    end
    if b.last_move_pawn_double_push > 0
        print(io, "   en passant from $(square_name(b.last_move_pawn_double_push))")
    end
    print(io, "\n")

    for r in 8:-1:1
        print(io, "$(SMALL_NUMBERS[r])   ")
        for c in 1:8
            sqr = square(c, r)
            piece = piece_type_on_sqr(b, sqr)
            color = piece_color_on_sqr(b, sqr)
            s = character_for_piece(color, piece)
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
    print(io, "       ")
    if b.castling_rights & CASTLING_RIGHTS_WHITE_QUEENSIDE > 0
        print(io, CHARACTER_CASTLING_AVAILABLE)
    end
    print(io, "       ")
    if b.castling_rights & CASTLING_RIGHTS_WHITE_KINGSIDE > 0
        print(io, CHARACTER_CASTLING_AVAILABLE)
    end
    print(io, "\n")
    #println("    a b c d e f g h")
    #println("    ᵃ ᵇ ᶜ ᵈ ᵉ ᶠ ᵍ ᴴ")
    #println("    𝑎 𝑏 𝑐 𝑑 𝑒 𝑓 𝑔 h")
    #println("    𝔞 𝔟 𝔠 𝔡 𝔢 𝔣 𝔤 𝔥")
    #println("    𝖠 𝖡 𝖢 𝖣 𝖤 𝖥 𝖦 𝖧")
    #println("    𝕒 𝕓 𝕔 𝕕 𝕖 𝕗 𝕘 𝕙")
    print(io, "    𝖺 𝖻 𝖼 𝖽 𝖾 𝖿 𝗀 𝗁")
    print(io, "   Score $(evaluate(b)/100) pawns\n")
end

function square(square_name::String)
    assert(length(square_name)==2)
    file = parse(Integer, square_name[1]-48)
    rank = parse(Integer, square_name[2])
    square(file, rank)
end

function read_fen(fen::String)
    b = Board()
    # r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -
    file = 1
    rank = 8
    splitfen = split(fen, " ")
    for t in splitfen[1]
        if t=='K' set!(b, WHITE, KING,   file, rank)
        elseif t=='Q' set!(b, WHITE, QUEEN,   file, rank)
        elseif t=='R' set!(b, WHITE, ROOK,   file, rank)
        elseif t=='B' set!(b, WHITE, BISHOP,   file, rank)
        elseif t=='N' set!(b, WHITE, KNIGHT,   file, rank)
        elseif t=='P' set!(b, WHITE, PAWN,   file, rank)
        elseif t=='k' set!(b, BLACK, KING,   file, rank)
        elseif t=='q' set!(b, BLACK, QUEEN,   file, rank)
        elseif t=='r' set!(b, BLACK, ROOK,   file, rank)
        elseif t=='b' set!(b, BLACK, BISHOP,   file, rank)
        elseif t=='n' set!(b, BLACK, KNIGHT,   file, rank)
        elseif t=='p' set!(b, BLACK, PAWN,   file, rank)
        elseif isnumber(t) file += parse(Integer,t)-1
        elseif t=='/'
            rank -= 1
            file = 0
        end
        file += 1
    end

    white_to_move = (splitfen[2]=="w")
    if white_to_move
        b.side_to_move = WHITE
    else
        b.side_to_move = BLACK
    end

    b.castling_rights = 0x00
    for t in splitfen[3]
        if t=='K' b.castling_rights = b.castling_rights | CASTLING_RIGHTS_WHITE_KINGSIDE
        elseif t=='Q' b.castling_rights = b.castling_rights | CASTLING_RIGHTS_WHITE_QUEENSIDE
        elseif t=='k' b.castling_rights = b.castling_rights | CASTLING_RIGHTS_BLACK_KINGSIDE
        elseif t=='q' b.castling_rights = b.castling_rights | CASTLING_RIGHTS_BLACK_QUEENSIDE
        end
    end

    if splitfen[4]!="-"
        b.last_move_pawn_double_push = square(splitfen[4])
    end

    b
end

function write_fen(b::Board)
    fen = ""
    empty_squares = 0
    for rank in 8:-1:1
        for file in 1:8
            sqr = square(file, rank)
            if (b.white_pieces & sqr > 0 || b.black_pieces & sqr > 0) && empty_squares > 0
                fen *= string(empty_squares)
                empty_squares = 0
            end
            if b.white_pieces & sqr > 0
                if b.kings & sqr > 0   fen *= "K" end
                if b.queens & sqr > 0  fen *= "Q" end
                if b.rooks & sqr > 0   fen *= "R" end
                if b.bishops & sqr > 0 fen *= "B" end
                if b.knights & sqr > 0 fen *= "N" end
                if b.pawns & sqr > 0   fen *= "P" end
            elseif b.black_pieces & sqr > 0
                if b.kings & sqr > 0   fen *= "k" end
                if b.queens & sqr > 0  fen *= "q" end
                if b.rooks & sqr > 0   fen *= "r" end
                if b.bishops & sqr > 0 fen *= "b" end
                if b.knights & sqr > 0 fen *= "n" end
                if b.pawns & sqr > 0   fen *= "p" end
            else
                empty_squares += 1
            end
        end # for file in 1:8
        if empty_squares > 0
            fen *= string(empty_squares)
        end
        if rank>1
            fen *= "/"
        end
        empty_squares = 0
    end
    fen *= " "
    if b.side_to_move==WHITE
        fen *= "w"
    else
        fen *= "b"
    end
    fen *= " "
    if b.castling_rights & CASTLING_RIGHTS_WHITE_KINGSIDE > 0 fen *= "K" end
    if b.castling_rights & CASTLING_RIGHTS_WHITE_QUEENSIDE > 0 fen *= "Q" end
    if b.castling_rights & CASTLING_RIGHTS_BLACK_KINGSIDE > 0 fen *= "k" end
    if b.castling_rights & CASTLING_RIGHTS_BLACK_QUEENSIDE > 0 fen *= "q" end
    fen *= " "
    if b.last_move_pawn_double_push > 0
        sqr = b.last_move_pawn_double_push
        if b.side_to_move==WHITE
            sqr = sqr << 8
        else
            sqr = sqr >> 8
        end
        fen *= square_name(sqr)
    else
        fen *= "-"
    end


    fen
end

function draw_with_fonts()
    # convert -size 360x360 xc:white -font "FreeMono" -pointsize 12 -fill black -draw @ascii.txt image.png
    # use alpha2 chess diagram font
end

function board_validation_checks(b::Board)
    # check no overlap - each square can have one and only one piece
    assert(b.side_to_move!=NONE)

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
    n_white_pieces = count(b.white_pieces)
    n_black_pieces = count(b.black_pieces)

    n_kings = count(b.kings)
    n_queens = count(b.queens)
    n_rooks = count(b.rooks)
    n_bishops = count(b.bishops)
    n_knights = count(b.knights)
    n_pawns = count(b.pawns)

    t1 = n_white_pieces + n_black_pieces
    t2 = n_kings + n_queens + n_rooks + n_bishops + n_knights + n_pawns
    @assert t1==t2  "$b"
end
