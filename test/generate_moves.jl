# perft_runs.jl

#
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

# r3k2r/p1ppqpb1/bn2Pnp1/4N3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R b KQkq -
# r3k2r/p1pp1pb1/bn1qPnp1/4N3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -
# r3k2r/p1ppPpb1/bn1q1np1/4N3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R b KQkq -

function test_perft_runs()
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
            time_start_ns = time_ns()
            engine_count = perft(b, levels)
            time_s = (time_ns() - time_start_ns)*1e-9
            kilonodes_per_sec = round((engine_count/1000)/time_s; digits=3)
            print("$count\t $engine_count nodes\t $kilonodes_per_sec kN/sec\t ")
            if count!=engine_count
                printstyled("FAIL\n"; color=:red)
                @assert false
                break
            end
            printstyled("pass\n"; color=:green)
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
    #@show number_of_moves(b.game_movelist)
    #@show b.game_movelist
    @assert length(moves) == 4
end

test_perft_runs()
test_no_castling_in_check()
