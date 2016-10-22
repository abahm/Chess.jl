# runtests.jl

if pwd()∉LOAD_PATH
    push!(LOAD_PATH, pwd())
end

using Chess

function test_position_1()
    b = Board()

    set!(b, WHITE, ROOK, E, 2)
    set!(b, BLACK, PAWN, E, 5)

    b.side_to_move = WHITE

    moves = generate_moves(b)
    printbd(b,moves)
    m = moves[11]

    make_move!(b, m)

    printbd(b)
end

function test_position_2()
    b = new_game()
    printbd(b)

    moves = generate_moves(b)
    print_algebraic(moves)
    m = moves[12]  # d4
    print_algebraic(m)
    make_move!(b, m)
    printbd(b)

    moves = generate_moves(b)
    print_algebraic(moves)
    m = moves[10]  # e5
    print_algebraic(m)
    make_move!(b, m)
    printbd(b)

    moves = generate_moves(b,)
    print_algebraic(moves)
    m = moves[29]  # d4
    print_algebraic(m)
    make_move!(b, m)
    printbd(b)

    moves = generate_moves(b, )
    print_algebraic(moves)
    m = moves[10]  # d4
    print_algebraic(m)
    make_move!(b, m)
    printbd(b)
end

function test_position_3()

    b = Board()

    set!(b, WHITE, ROOK, A, 1)
    set!(b, WHITE, ROOK, B, 1)
    set!(b, WHITE, ROOK, C, 1)
    set!(b, WHITE, ROOK, D, 1)
    set!(b, WHITE, ROOK, E, 1)
    set!(b, BLACK, QUEEN, B, 7)
    set!(b, BLACK, QUEEN, C, 7)
    set!(b, BLACK, QUEEN, D, 7)
    set!(b, BLACK, QUEEN, E, 7)
    set!(b, BLACK, QUEEN, F, 7)

    b
end

function test_position_4()
    b = Board()
    set!(b, WHITE, PAWN, A, 5)
    set!(b, BLACK, PAWN, H, 5)
    b.side_to_move = WHITE
    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
end

function test_enpassant()
    # https://github.com/official-stockfish/Stockfish
    b = Board()
    set!(b, WHITE, PAWN, D, 2)
    set!(b, BLACK, PAWN, C, 4)
    set!(b, BLACK, PAWN, E, 4)
    b.side_to_move = WHITE
    printbd(b)

    moves = generate_moves(b)
    print_algebraic(moves)
    make_move!(b,moves[2])
    printbd(b)

    moves = generate_moves(b, moves[2].sqr_dest)
    print_algebraic(moves)
    make_move!(b,moves[2])
    printbd(b)
end

function test_castling()
    b = Board()
    #@show b.castling_rights
    #b.castling_rights = CASTLING_RIGHTS_WHITE_KINGSIDE
    #@show b.castling_rights
    set!(b, WHITE, KING, E, 1)
    set!(b, WHITE, ROOK, H, 1)
    set!(b, WHITE, ROOK, A, 1)
    b.side_to_move = WHITE

    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
    m = moves[17]
    print_algebraic(m)

    make_move!(b, m)
    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
    m = moves[5]
    print_algebraic(m)

    make_move!(b, m)
    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
end

function test_king_moves()
    b = Board()
    set!(b, WHITE, KING, E, 5)
    set!(b, BLACK, ROOK, D, 8)
    set!(b, BLACK, ROOK, F, 8)
    set!(b, BLACK, ROOK, A, 6)
    set!(b, BLACK, ROOK, A, 4)
    b.side_to_move = WHITE
    b.castling_rights = 0x00
    b.last_move_pawn_double_push = square(C, 5)
    printbd(b)

    moves = generate_moves(b)
    print_algebraic(moves)
end

function test_pins()
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
    b.side_to_move = WHITE
    b.castling_rights = 0x00
    b.last_move_pawn_double_push = square(C, 5)
    printbd(b)

    moves = generate_moves(b)
    print_algebraic(moves)
end

function test_fen()
    for (name,fen) in perft_data
        println("$name $fen")
        b, = read_fen(fen)
        printbd(b)
        for i in 1:3
            tic()
            nodes = perft(b, i,)
            t = toq()
            println("$i   $nodes nodes  $(round(t,4)) s  $(round(nodes/(t*1000),2)) kn/s")
        end
        println()
        println()
    end
end

function test_position_6()
    b = Board()
    set!(b, WHITE, PAWN, A, 7)
    #set!(b, BLACK, PAWN, H, 2)
    b.side_to_move = WHITE
    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
    make_move!(b, moves[1])
    printbd(b)
end

function test_position_7()
    b, = read_fen(perft_data[4][2])
    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
end

function test_position_8()
    b, = read_fen(perft_data[3][2])
    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
    println("================================================")
    println("================================================")
    for m in moves
        println()
        println()
        test_board = deepcopy(b)
        make_move!(test_board, m)
        printbd(test_board)
        reply_moves = generate_moves(test_board)
        print_algebraic(reply_moves)
    end
end

function test_position_9()
    b = read_fen(perft_data[3][2])
    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
    println("================================================")
    println("================================================")
    cnt = 0
    for m in moves
        println()
        println()
        print_algebraic(m)
        test_board = deepcopy(b)
        make_move!(test_board, m)
        printbd(test_board)
        reply_moves = generate_moves(test_board)
        print_algebraic(reply_moves)
        @show length(reply_moves)
        cnt += length(reply_moves)
    end
    @show cnt
end


function perft_runs()
    println("Running perft ...")
    for pd in perft_data
        desc, fen, correct_results = pd[1], pd[2], pd[3]
        println(desc)
        println("FEN $fen")
        b = read_fen(fen)
        printbd(b)
        for (levels, count) in enumerate(correct_results)
            # computation time too long at higher levels
            if levels==5
                break
            end
            engine_count = perft(b, levels)
            print("$count  $engine_count  ")
            if count!=engine_count
                print_with_color(:red, "FAIL\n")
                return
                break
            end
            print_with_color(:green, "pass\n")
        end
        println()
        println()
    end
end

perft_runs()

println("Tests complete!")
