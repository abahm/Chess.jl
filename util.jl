# util.jl


# https://chessprogramming.wikispaces.com/Perft+Results
#
perft_fens = [
("perft_fen1", "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"),
("perft_fen2", "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -"),
("perft_fen3", "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - -"),
("perft_fen4", "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"),
("perft_fen4_alt", "r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1"),
("perft_fen5", "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8 "),
("perft_fen6", "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10"),
]




function square(c::Integer, r::Integer)
    sqr = UInt64(1) << ((c-1) + 8*(r-1))
    sqr
end

function column_row(sqr::UInt64)
    square_index = Integer(log2(sqr))
    # n.b. ÷ gives integer quotient like div()
    row = (square_index-1)÷8 + 1
    column = ((square_index-1) % 8) + 1
    (column,row)
end

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

function square_name(sqrs::Array{UInt64,1})
    output = ""
    for s in sqrs
        output = output * square_name(s) * " "
    end
    output
end



CHARACTER_KING, CHARACTER_QUEEN, CHARACTER_ROOK, CHARACTER_BISHOP, CHARACTER_KNIGHT, CHARACTER_PAWN = 'k','q','r','b','n','p'
CHARACTER_KING, CHARACTER_QUEEN, CHARACTER_ROOK, CHARACTER_BISHOP, CHARACTER_KNIGHT, CHARACTER_PAWN = '♔','♕','♖','♗','♘','♙'
function character_for_piece(color, piece)
    s = CHARACTER_SQUARE_EMPTY
    if     piece==KING    s = CHARACTER_KING
    elseif piece==QUEEN   s = CHARACTER_QUEEN
    elseif piece==ROOK    s = CHARACTER_ROOK
    elseif piece==BISHOP  s = CHARACTER_BISHOP
    elseif piece==KNIGHT  s = CHARACTER_KNIGHT
    elseif piece==PAWN    s = CHARACTER_PAWN
    end
    if color==WHITE
        s = s + 6
    end
    s
end
