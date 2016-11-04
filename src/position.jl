# position.jl

@inline function piece_type_on_sqr(b::Board, sqr::UInt64)
    if (b.kings   & sqr)>0  return KING    end
    if (b.queens  & sqr)>0  return QUEEN   end
    if (b.rooks   & sqr)>0  return ROOK    end
    if (b.bishops & sqr)>0  return BISHOP  end
    if (b.knights & sqr)>0  return KNIGHT  end
    if (b.pawns   & sqr)>0  return PAWN    end
    return NONE
end

@inline function piece_color_on_sqr(b::Board, sqr::UInt64)
    if (b.white_pieces & sqr)>0  return WHITE  end
    if (b.black_pieces & sqr)>0  return BLACK  end
    return NONE
end

@inline function occupied_by(b::Board, sqr::UInt64)
    # alias for piece_color_on_sqr()
    return piece_color_on_sqr(b, sqr)
end

# handle adding sliding moves of QUEEN, ROOK, BISHOP
#  which end by being BLOCKED or capturing an enemy piece
const UNBLOCKED = UInt8(0)
const BLOCKED = UInt8(1)
@inline function add_move!(moves, b::Board,
                           my_color::UInt8, my_piece::UInt8,
                           src_sqr::UInt64, dest_sqr::UInt64;
                           promotion_to::UInt8=NONE,
                           en_passant_sqr::UInt64=UInt64(0))
    # move is off the board
    if dest_sqr==0
        return BLOCKED
    end

    o = occupied_by(b,dest_sqr)

    # move is blocked by one of my own pieces
    if o==my_color
        return BLOCKED
    end

    # move is a capturing move
    if o!=NONE
        m = Move(my_color, my_piece, src_sqr, dest_sqr, piece_taken=piece_type_on_sqr(b,dest_sqr), promotion_to=promotion_to)
        push!(moves, m)
        return BLOCKED
    end

    # move to an empty square
    m = Move(my_color, my_piece, src_sqr, dest_sqr, promotion_to=promotion_to, sqr_ep=en_passant_sqr)
    push!(moves, m)

    return UNBLOCKED
end

function generate_moves(b::Board; only_attacking_moves=false)
    my_color = b.side_to_move
    assert(my_color==WHITE || my_color==BLACK)
    enemy_color = opposite_color(my_color)
    moves = Move[]

    attacking_moves = Move[]
    attacked_squares = UInt64[]
    if !only_attacking_moves
        b.side_to_move = enemy_color
        attacking_moves = generate_moves(b, only_attacking_moves=true)
        b.side_to_move = my_color
        attacked_squares = [m.sqr_dest for m in attacking_moves]
    end

    # is king in check?
    kings_square = b.kings & (my_color==WHITE ? b.white_pieces : b.black_pieces)
    if kings_square == UInt64(0)
        return moves # empty list
    end
    assert( kings_square > 0 ) # can't find the king!
    king_in_check = kings_square ∈ attacked_squares
    my_color_str = my_color==WHITE?"WHITE":"BLACK"
    #@show my_color_str, king_in_check

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
            new_sqr = (sqr>>9) & ~FILE_H
            if new_sqr ∉ attacked_squares  # can't move into check
                add_move!(moves, b, my_color, KING, sqr, new_sqr)
            end
            new_sqr = (sqr>>8)
            if new_sqr ∉ attacked_squares  # can't move into check
                add_move!(moves, b, my_color, KING, sqr, new_sqr)
            end
            new_sqr = (sqr>>7) & ~FILE_A
            if new_sqr ∉ attacked_squares  # can't move into check
                add_move!(moves, b, my_color, KING, sqr, new_sqr)
            end
            new_sqr = (sqr>>1) & ~FILE_H
            if new_sqr ∉ attacked_squares  # can't move into check
                add_move!(moves, b, my_color, KING, sqr, new_sqr)
            end
            new_sqr = (sqr<<1) & ~FILE_A
            if new_sqr ∉ attacked_squares  # can't move into check
                add_move!(moves, b, my_color, KING, sqr, new_sqr)
            end
            new_sqr = (sqr<<7) & ~FILE_H
            if new_sqr ∉ attacked_squares  # can't move into check
                add_move!(moves, b, my_color, KING, sqr, new_sqr)
            end
            new_sqr = (sqr<<8)
            if new_sqr ∉ attacked_squares  # can't move into check
                add_move!(moves, b, my_color, KING, sqr, new_sqr)
            end
            new_sqr = (sqr<<9) & ~FILE_A
            if new_sqr ∉ attacked_squares  # can't move into check
                add_move!(moves, b, my_color, KING, sqr, new_sqr)
            end

            # castling kingside
            if !king_in_check && !only_attacking_moves
                kings_travel_sqrs = []
                rooks_travel_sqrs = []
                if my_color == WHITE
                    # check for castling rights
                    if b.castling_rights & CASTLING_RIGHTS_WHITE_KINGSIDE > 0
                        kings_travel_sqrs = [SQUARE_F1, SQUARE_G1]
                        rooks_travel_sqrs = [SQUARE_G1]
                    end
                elseif my_color == BLACK
                    # check for castling rights
                    if b.castling_rights & CASTLING_RIGHTS_BLACK_KINGSIDE > 0
                        kings_travel_sqrs = [SQUARE_F8, SQUARE_G8]
                        rooks_travel_sqrs = [SQUARE_G8]
                    end
                end

                if length(kings_travel_sqrs)>0 &&
                    # check that the king's travel squares are empty
                    reduce(&, Bool[piece_type_on_sqr(b, s)==NONE for s in kings_travel_sqrs]) &&
                    # check that the rook's travel squares are empty
                    reduce(&, Bool[piece_type_on_sqr(b, s)==NONE for s in rooks_travel_sqrs]) &&
                    # check that king's traversal squares are not attacked
                    reduce(&, Bool[s ∉ attacked_squares for s in kings_travel_sqrs])
                        push!(moves, Move(my_color, KING, sqr, kings_travel_sqrs[end],
                                          castling=CASTLING_RIGHTS_WHITE_KINGSIDE) )
                end

                # castling queenside (allows for chess960 castling too)
                kings_travel_sqrs = []
                if my_color == WHITE
                    # check for castling rights
                    if b.castling_rights & CASTLING_RIGHTS_WHITE_QUEENSIDE > 0
                        kings_travel_sqrs = [SQUARE_D1, SQUARE_C1]
                        rooks_travel_sqrs = [SQUARE_B1, SQUARE_C1]
                    end
                elseif my_color == BLACK
                    # check for castling rights
                    if b.castling_rights & CASTLING_RIGHTS_BLACK_QUEENSIDE > 0
                        kings_travel_sqrs = [SQUARE_D8, SQUARE_C8]
                        rooks_travel_sqrs = [SQUARE_B8, SQUARE_C8]
                    end
                end
                if length(kings_travel_sqrs)>0 &&
                    # check that the kings travel squares are empty
                    reduce(&, Bool[piece_type_on_sqr(b, s)==NONE for s in kings_travel_sqrs]) &&
                    # check that the rook's travel squares are empty
                    reduce(&, Bool[piece_type_on_sqr(b, s)==NONE for s in rooks_travel_sqrs]) &&
                    # check that king's traversal squares are not attacked
                    reduce(&, Bool[s ∉ attacked_squares for s in kings_travel_sqrs])
                        push!(moves, Move(my_color, KING, sqr, kings_travel_sqrs[end],
                                          castling=CASTLING_RIGHTS_WHITE_QUEENSIDE )  )
                end
            end # castling moves
        end # king

        # rook moves
        queen = sqr & b.queens
        rook = sqr & b.rooks
        my_piece = queen > 0 ? QUEEN : ROOK
        if rook > 0 || queen > 0
            for i in 1:7
                new_sqr = sqr>>i
                if new_sqr & FILE_H > 0
                    break
                end
                if add_move!(moves, b, my_color, my_piece, sqr, new_sqr) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr<<i
                if new_sqr & FILE_A > 0
                    break
                end
                if add_move!(moves, b, my_color, my_piece, sqr, new_sqr) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr>>(i*8)
                if add_move!(moves, b, my_color, my_piece, sqr, new_sqr) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr<<(i*8)
                if add_move!(moves, b, my_color, my_piece, sqr, new_sqr) == BLOCKED
                    break
                end
            end
        end

        # bishop moves
        bishop = sqr & b.bishops
        my_piece = queen > 0 ? QUEEN : BISHOP
        if bishop > 0 || queen > 0
            for i in 1:7
                new_sqr = sqr>>(i*9)
                if new_sqr & FILE_H > 0
                    break
                end
                if add_move!(moves, b, my_color, my_piece, sqr, new_sqr) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr>>(i*7)
                if new_sqr & FILE_A > 0
                    break
                end
                if add_move!(moves, b, my_color, my_piece, sqr, new_sqr) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr<<(i*7)
                if new_sqr & FILE_H > 0
                    break
                end
                if add_move!(moves, b, my_color, my_piece, sqr, new_sqr) == BLOCKED
                    break
                end
            end
            for i in 1:7
                new_sqr = sqr<<(i*9)
                if new_sqr & FILE_A > 0
                    break
                end
                if add_move!(moves, b, my_color, my_piece, sqr, new_sqr) == BLOCKED
                    break
                end
            end
        end

        # knight moves
        knight = sqr & b.knights
        if knight > 0
            add_move!(moves, b, my_color, KNIGHT, sqr, (sqr & ~FILE_A)>>17)
            add_move!(moves, b, my_color, KNIGHT, sqr, (sqr & ~FILE_AB)>>10)
            add_move!(moves, b, my_color, KNIGHT, sqr, (sqr & ~FILE_AB)<<6)
            add_move!(moves, b, my_color, KNIGHT, sqr, (sqr & ~FILE_A)<<15)

            add_move!(moves, b, my_color, KNIGHT, sqr, (sqr & ~FILE_H)>>15)
            add_move!(moves, b, my_color, KNIGHT, sqr, (sqr & ~FILE_GH)<<10)
            add_move!(moves, b, my_color, KNIGHT, sqr, (sqr & ~FILE_GH)>>6)
            add_move!(moves, b, my_color, KNIGHT, sqr, (sqr & ~FILE_H)<<17)
        end

        # pawn moves
        pawn = sqr & b.pawns
        my_piece = PAWN
        if pawn > 0
            ONE_SQUARE_FORWARD = 8
            TWO_SQUARE_FORWARD = 16
            TAKE_LEFT = 7
            TAKE_RIGHT = 9
            START_RANK = 2
            LAST_RANK = 7
            bitshift_direction = <<
            if my_color==BLACK
                TAKE_LEFT = 9
                TAKE_RIGHT = 7
                START_RANK = 7
                LAST_RANK = 2
                bitshift_direction = >>
            end
            new_sqr = bitshift_direction(sqr, ONE_SQUARE_FORWARD)
            if occupied_by(b, new_sqr) == NONE  && !only_attacking_moves
                if row == LAST_RANK
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=QUEEN)
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=KNIGHT)
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=ROOK)
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=BISHOP)
                else
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr)
                end
                if row == START_RANK
                    new_sqr = bitshift_direction(sqr, TWO_SQUARE_FORWARD)
                    if occupied_by(b, new_sqr) == NONE
                        add_move!(moves, b, my_color, PAWN, sqr, new_sqr)
                    end
                end
            end
            new_sqr = bitshift_direction(sqr, TAKE_LEFT) & ~FILE_H
            if occupied_by(b, new_sqr) == enemy_color || only_attacking_moves
                if row == LAST_RANK
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=QUEEN)
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=KNIGHT)
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=ROOK)
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=BISHOP)
                else
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr)
                end
            end
            # en passant
            if b.last_move_pawn_double_push > 0 &&
                new_sqr == bitshift_direction(b.last_move_pawn_double_push, ONE_SQUARE_FORWARD) &&
                !only_attacking_moves
                add_move!(moves, b, my_color, PAWN, sqr, new_sqr, en_passant_sqr=b.last_move_pawn_double_push)
            end
            new_sqr = bitshift_direction(sqr, TAKE_RIGHT) & ~FILE_A
            if occupied_by(b, new_sqr) == enemy_color || only_attacking_moves
                if row == LAST_RANK
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=QUEEN)
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=KNIGHT)
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=ROOK)
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr, promotion_to=BISHOP)
                else
                    add_move!(moves, b, my_color, PAWN, sqr, new_sqr)
                end
            end
            # en passant
            if b.last_move_pawn_double_push > 0 &&
                new_sqr == bitshift_direction(b.last_move_pawn_double_push, ONE_SQUARE_FORWARD) &&
                !only_attacking_moves
                add_move!(moves, b, my_color, PAWN, sqr, new_sqr, en_passant_sqr=b.last_move_pawn_double_push)
            end
        end  #  if pawn > 0
    end # for square_index in 1:64

    if !only_attacking_moves
        # PINNED pieces
        # check for pieces pinned to the king
        #   and remove any moves by them
        # PLAN: find king's unique square
        #       find any enemy queens,rooks,bishops on same file/columm/diagonal as king
        #       check if there is only an interposing mycolor piece
        #       remove any moves by that piece away from that file/columm/diagonal
        # OR,
        #       simply run the ply, make each move, and if the enemy response allows king capture,
        #       remove it from the list
        illegal_moves = []
        for move in moves
            test_board = deepcopy(b)
            make_move!(test_board,move)
            kings_new_square = test_board.kings & (my_color==WHITE ? b.white_pieces : b.black_pieces)
            if move.piece_moving==KING
                kings_new_square = move.sqr_dest
            end
            #println("Checking $(m) for pins against KING on $(square_name(kings_new_square))")
            reply_moves = generate_moves(test_board, only_attacking_moves=true)
            for reply_move in reply_moves
                #@show reply_move
                if reply_move.sqr_dest == kings_new_square
                    #println(" filtering illegal mv  $(algebraic_move(m))")
                    push!(illegal_moves, move)
                    break
                end
            end
        end
        filter!(mv -> mv ∉ illegal_moves, moves)
    end


    # TODO: order moves by captures first

    # TODO: order moves so that a capture of last moved piece is first

    moves
end

function make_move!(b::Board, movestr::String)
    move = nothing
    moves = generate_moves(b)
    for m in moves
        if long_algebraic_move(m)==movestr
            make_move!(b,m)
            move = m
            break
        end
    end
    move
end

function make_move!(b::Board, m::Move)
    sqr_src = m.sqr_src
    sqr_dest = m.sqr_dest
    color = piece_color_on_sqr(b,sqr_src)
    assert(color!=NONE)
    moving_piece = piece_type_on_sqr(b,sqr_src)
    assert(moving_piece!=NONE)
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
        if color == WHITE      b.white_pieces = b.white_pieces | sqr_dest
        elseif color == BLACK  b.black_pieces = b.black_pieces | sqr_dest
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
    if sqr_dest == SQUARE_A1      b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_WHITE_QUEENSIDE
    elseif sqr_dest == SQUARE_H1  b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_WHITE_KINGSIDE
    elseif sqr_dest == SQUARE_A8  b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_BLACK_QUEENSIDE
    elseif sqr_dest == SQUARE_H8  b.castling_rights = b.castling_rights & ~CASTLING_RIGHTS_BLACK_KINGSIDE
    end

    # castling - move rook in addition to the king
    if m.castling > 0
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

    if b.side_to_move == WHITE
        b.side_to_move = BLACK
    elseif b.side_to_move == BLACK
        b.side_to_move = WHITE
    end

    board_validation_checks(b)

    nothing
end

function is_king_in_check(b::Board)
    # generate enemies attacking moves
    b.side_to_move = opposite_color(b.side_to_move)
    moves = generate_moves(b, only_attacking_moves=true)
    b.side_to_move = opposite_color(b.side_to_move)

    # check if any enemy piece can capture the king
    kings_square = b.kings & (b.side_to_move==WHITE ? b.white_pieces : b.black_pieces)
    for m in moves
        if m.sqr_dest == kings_square
            return true  # king taken!
        end
    end
    return false
end

function unmake_move!(b::Board, m::Move, prior_castling_rights, prior_last_move_pawn_double_push)
    sqr_src = m.sqr_src
    sqr_dest = m.sqr_dest
    color = m.color_moving
    moving_piece = m.piece_moving
    taken_piece = m.piece_taken

    # undo any pawn promotion
    if m.promotion_to != NONE
        b.pawns = b.pawns | sqr_dest
        if m.promotion_to == QUEEN       b.queens = b.queens & ~sqr_dest
        elseif m.promotion_to == KNIGHT  b.knights = b.knights & ~sqr_dest
        elseif m.promotion_to == ROOK    b.rooks = b.rooks & ~sqr_dest
        elseif m.promotion_to == BISHOP  b.bishops = b.bishops & ~sqr_dest
        end
        #if color == WHITE      b.white_pieces = b.white_pieces & ~sqr_dest
        #elseif color == BLACK  b.black_pieces = b.black_pieces & ~sqr_dest
        #end # this is done below
    end

    # move the moving piece (remove from dest, add to src)
    if moving_piece == KING         b.kings =   (b.kings & ~sqr_dest) | sqr_src
    elseif moving_piece == QUEEN    b.queens =  (b.queens & ~sqr_dest) | sqr_src
    elseif moving_piece == ROOK     b.rooks =   (b.rooks & ~sqr_dest) | sqr_src
    elseif moving_piece == BISHOP   b.bishops = (b.bishops & ~sqr_dest) | sqr_src
    elseif moving_piece == KNIGHT   b.knights = (b.knights & ~sqr_dest) | sqr_src
    elseif moving_piece == PAWN     b.pawns =   (b.pawns & ~sqr_dest) | sqr_src
    end
    # update the moving color (remove from dest, add to src)
    if color==WHITE
        b.white_pieces = (b.white_pieces & ~sqr_dest) | sqr_src
    else
        b.black_pieces = (b.black_pieces & ~sqr_dest) | sqr_src
    end

    # TODO: switch to XOR for simplicity? speed   Also calculated src | dest once

    # add back any piece taken square
    if taken_piece != NONE
        if taken_piece == QUEEN   b.queens = b.queens | sqr_dest  end
        if taken_piece == ROOK    b.rooks = b.rooks | sqr_dest  end
        if taken_piece == BISHOP  b.bishops = b.bishops | sqr_dest  end
        if taken_piece == KNIGHT  b.knights = b.knights | sqr_dest  end
        if taken_piece == PAWN && m.sqr_ep == 0  b.pawns = b.pawns | sqr_dest  end
        if color==WHITE           b.black_pieces = b.black_pieces | sqr_dest
        else                      b.white_pieces = b.white_pieces | sqr_dest
        end
    end

    # restore en passant marker
    b.last_move_pawn_double_push = prior_last_move_pawn_double_push

    # en passant - replace any pawn taken by en passant
    if m.sqr_ep != 0
        b.pawns = b.pawns | m.sqr_ep
        if color==WHITE  b.black_pieces = b.black_pieces | m.sqr_ep
        else             b.white_pieces = b.white_pieces | m.sqr_ep
        end
    end

    # castling - move rook in addition to the king
    if m.castling > 0
        if sqr_dest == SQUARE_C1
            b.rooks = (b.rooks | SQUARE_A1) & ~SQUARE_D1
            b.white_pieces = (b.white_pieces | SQUARE_A1) & ~SQUARE_D1
        elseif sqr_dest == SQUARE_G1
            b.rooks = (b.rooks | SQUARE_H1) & ~SQUARE_F1
            b.white_pieces = (b.white_pieces | SQUARE_H1) & ~SQUARE_F1
        elseif sqr_dest == SQUARE_C8
            b.rooks = (b.rooks | SQUARE_A8) & ~SQUARE_D8
            b.black_pieces = (b.black_pieces | SQUARE_A8) & ~SQUARE_D8
        elseif sqr_dest == SQUARE_G8
            b.rooks = (b.rooks | SQUARE_H8) & ~SQUARE_F8
            b.black_pieces = (b.black_pieces | SQUARE_H8) & ~SQUARE_F8
        end
    end

    # restore castling rights
    b.castling_rights = prior_castling_rights

    # change back the side to move
    b.side_to_move = opposite_color(b.side_to_move)

    board_validation_checks(b)

    nothing
end
