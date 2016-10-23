# util.jl


# https://chessprogramming.wikispaces.com/Perft+Results
#
const perft_data = [
("perft_fen1", "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", [20, 400, 8902, 197281, 4865609, 119060324, 3195901860]),
("perft_fen2", "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -", [48, 2039, 97862, 4085603, 193690690]),
("perft_fen3", "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - -", [14, 191, 2812, 43238, 674624, 11030083, 178633661]),
("perft_fen4", "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1", [6, 264, 9467, 422333, 15833292, 706045033]),
("perft_fen4_alt", "r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1", [6, 264, 9467, 422333, 15833292, 706045033]),
("perft_fen5", "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8 ", [44, 1486, 62379, 2103487, 89941194]),
("perft_fen6", "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10", [46, 2079, 89890, 3894594, 164075551]),
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

#CHARACTERS = ['k','q','r','b','n','p']
const CHARACTERS = ['♔','♕','♖','♗','♘','♙']
function character_for_piece(color, piece)
    if piece==0
        return CHARACTER_SQUARE_EMPTY
    end

    s = CHARACTERS[piece]
    if color==WHITE
        s = s + 6
    end
    s
end

@inline function Base.count(bit_mask::UInt64)
    count(i->i=='1', bits(bit_mask))
end
