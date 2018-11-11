# pinned.jl

function test_pinned_pieces_still_attack_enemy_king()
    println("Checking test_pinned_pieces_still_attack_enemy_king() ...")
    b = read_fen("rnQq1k1r/pp2bppp/2p5/8/2B5/8/PPP1N1PP/RNBnK2R w KQ -")
    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
    @assert length(moves) == 43
end

function test_pins()
    println("Checking test_pins() ...")
    b = Board()
    set!(b, WHITE, KING, E, 5)
    set!(b, WHITE, PAWN, D, 5)
    set!(b, BLACK, PAWN, C, 5)
    set!(b, BLACK, ROOK, A, 5)
    set!(b, WHITE, PAWN, G, 5)
    set!(b, BLACK, QUEEN, H, 5)
    set!(b, WHITE, KNIGHT, C, 7)
    set!(b, BLACK, BISHOP, B, 8)
    set!(b, BLACK, KNIGHT, G, 3)
    set!(b, BLACK, KING, H, 8)
    b.side_to_move = WHITE
    b.castling_rights = 0x00
    b.last_move_pawn_double_push = square(C, 5)
    printbd(b)

    moves = generate_moves(b)
    print_algebraic(moves)
    @assert length(moves) == 5
end


test_pinned_pieces_still_attack_enemy_king()
test_pins()
