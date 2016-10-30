# runtests.jl

# put Chess.jl in your load path (for this session only)
if pwd()∉LOAD_PATH  push!(LOAD_PATH, pwd())  end
# load the Chess.jl module for testing
using Chess

tic()

function test_mate_in_one()
    b = read_fen("8/8/8/8/8/7k/6rr/K7 b  -")
    printbd(b)
    for i in 1:7
        tic()
        nodes = perft(b, i,)
        t = toq()
        println("$i   $nodes nodes  $(round(t,4)) s  $(round(nodes/(t*1000),2)) kn/s")
    end
    println()
    println()
end

function test_fen()
    for (name,fen) in perft_data
        println("$name $fen")
        b = read_fen(fen)
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

function test_no_castling_in_check()
    println("Checking test_no_castling_in_check() ...")
    b = Board()
    set!(b, WHITE, KING, E, 1)
    set!(b, WHITE, ROOK, H, 1)
    set!(b, BLACK, KNIGHT, D, 3)
    set!(b, BLACK, KING, A, 8)
    b.side_to_move = WHITE
    b.castling_rights = CASTLING_RIGHTS_ALL
    printbd(b)

    moves = generate_moves(b)
    print_algebraic(moves)
    assert(length(moves)==4)
end

function test_pinned_pieces_still_attack_enemy_king()
    println("Checking test_pinned_pieces_still_attack_enemy_king() ...")
    b = read_fen("rnQq1k1r/pp2bppp/2p5/8/2B5/8/PPP1N1PP/RNBnK2R w KQ -")
    printbd(b)
    moves = generate_moves(b)
    print_algebraic(moves)
    assert(length(moves)==43)
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
    assert(length(moves)==5)
end

function perft_runs()
    println("Checking perft_runs() ...")
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

test_mate_in_one()
test_pinned_pieces_still_attack_enemy_king()
test_no_castling_in_check()
test_pins()
perft_runs()

println("Tests complete!")
toc()
