# evaluation.jl

const pawn_square_table = [
 0,  0,  0,  0,  0,  0,  0,  0,
 5, 10, 10,-20,-20, 10, 10,  5,
 5, -5,-10,  0,  0,-10, -5,  5,
 0,  0,  0, 20, 20,  0,  0,  0,
 5,  5, 10, 25, 25, 10,  5,  5,
10, 10, 20, 30, 30, 20, 10, 10,
50, 50, 50, 50, 50, 50, 50, 50,
 0,  0,  0,  0,  0,  0,  0,  0
 ]

const knight_square_table = [
-50,-40,-30,-30,-30,-30,-40,-50,
-40,-20,  0,  5,  5,  0,-20,-40,
-30,  5, 10, 15, 15, 10,  5,-30,
-30,  0, 15, 20, 20, 15,  0,-30,
-30,  5, 15, 20, 20, 15,  5,-30,
-30,  0, 10, 15, 15, 10,  0,-30,
-40,-20,  0,  0,  0,  0,-20,-40,
-50,-40,-30,-30,-30,-30,-40,-50
]

const bishop_square_table = [
-20,-10,-10,-10,-10,-10,-10,-20,
-10,  5,  0,  0,  0,  0,  5,-10,
-10, 10, 10, 10, 10, 10, 10,-10,
-10,  0, 10, 10, 10, 10,  0,-10,
-10,  5,  5, 10, 10,  5,  5,-10,
-10,  0,  5, 10, 10,  5,  0,-10,
-10,  0,  0,  0,  0,  0,  0,-10,
-20,-10,-10,-10,-10,-10,-10,-20
]

const rook_square_table = [
 0,  0,  0,  5,  5,  0,  0,  0,
-5,  0,  0,  0,  0,  0,  0, -5,
-5,  0,  0,  0,  0,  0,  0, -5,
-5,  0,  0,  0,  0,  0,  0, -5,
-5,  0,  0,  0,  0,  0,  0, -5,
-5,  0,  0,  0,  0,  0,  0, -5,
 5, 10, 10, 10, 10, 10, 10,  5,
 0,  0,  0,  0,  0,  0,  0,  0
]

const queen_square_table = [
-20,-10,-10, -5, -5,-10,-10,-20,
-10,  0,  5,  0,  0,  0,  0,-10,
-10,  5,  5,  5,  5,  5,  0,-10,
  0,  0,  5,  5,  5,  5,  0, -5,
 -5,  0,  5,  5,  5,  5,  0, -5,
-10,  0,  5,  5,  5,  5,  0,-10,
-10,  0,  0,  0,  0,  0,  0,-10,
-20,-10,-10, -5, -5,-10,-10,-20
]

const king_square_table = [
 20, 30, 10,  0,  0, 10, 30, 20,
 20, 20,  0,  0,  0,  0, 20, 20,
-10,-20,-20,-20,-20,-20,-20,-10,
-20,-30,-30,-40,-40,-30,-30,-20,
-30,-40,-40,-50,-50,-40,-40,-30,
-30,-40,-40,-50,-50,-40,-40,-30,
-30,-40,-40,-50,-50,-40,-40,-30,
-30,-40,-40,-50,-50,-40,-40,-30
]





function evaluate(b::Board)
    # simplified evaluation as per Tomasz Michniewski
    # https://chessprogramming.wikispaces.com/Simplified+evaluation+function
    material =
     20000 * count(b.white_pieces & b.kings)   +
       900 * count(b.white_pieces & b.queens)  +
       500 * count(b.white_pieces & b.rooks)   +
       330 * count(b.white_pieces & b.bishops) +
       320 * count(b.white_pieces & b.knights) +
       100 * count(b.white_pieces & b.pawns) -
    (20000 * count(b.black_pieces & b.kings)   +
       900 * count(b.black_pieces & b.queens)  +
       500 * count(b.black_pieces & b.rooks)   +
       330 * count(b.black_pieces & b.bishops) +
       320 * count(b.black_pieces & b.knights) +
       100 * count(b.black_pieces & b.pawns))

    position = 0
    for square_index in 1:64
        sqr = UInt64(1) << (square_index-1)

        i = square_index
        m = 1
        if b.black_pieces & sqr > 0
            i = 65-square_index
            m = -1
        end

        if b.kings & sqr > 0    position += m * king_square_table[i]    end
        if b.queens & sqr > 0   position += m * queen_square_table[i]   end
        if b.rooks & sqr > 0    position += m * rook_square_table[i]    end
        if b.bishops & sqr > 0  position += m * bishop_square_table[i]  end
        if b.knights & sqr > 0  position += m * knight_square_table[i]  end
        if b.pawns & sqr > 0    position += m * pawn_square_table[i]    end
    end

    material + position
end
