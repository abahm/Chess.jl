# chess.jl

module Chess

export perft, new_game
export random_play_both_sides, user_play_both_sides


include("constants.jl")
include("util.jl")
include("move.jl")
include("board.jl")
include("position.jl")



function perft(b::Board, levels::Integer, white_to_move::Bool=true)
    moves = generate_moves(b, white_to_move)
    if levels==1
        return length(moves)
    end

    count = 0
    saved_board = deepcopy(b)
    for m in moves
        #print_algebraic(m)
        make_move!(b, m)
        count = count + perft(b, levels-1, !white_to_move)
        b = deepcopy(saved_board)
    end
    return count
end

function random_play_both_sides(seed, show_move_history, delay=0.001, b=new_game(), max_number_of_moves=1000)
    srand(seed)
    n_white_pieces = count(i->i=='1', bits(b.white_pieces))
    n_black_pieces = count(i->i=='1', bits(b.black_pieces))
    white_to_move = true
    move_history = Move[]
    for i in 1:max_number_of_moves
        if show_move_history
            print("\033[2J")  # clear screen
            height = displaysize(STDOUT)[1]
            print("\033[$(height)A") # up 12 lines
        end
        println()
        printbd(b)

        if show_move_history
            for (j,move) in enumerate(move_history)
                if (j-1)%2==0
                    println()
                    print("$(floor(Integer,(j+1)/2)). ")
                end
                print(move)
                print(" \t")
            end
            println()
        end

        moves = generate_moves(b, white_to_move)
        if length(moves)==0
            break
        end
        #print_algebraic(moves)
        r = rand(1:length(moves))
        m = moves[r]

        make_move!(b, m)
        push!(move_history, m)

        white_to_move = !white_to_move
        sleep(delay)
    end
end

function random_play_both_sides(n)
    for random_seed in 1:n
        random_play_both_sides(random_seed, true, 0.1)
    end
end

function user_play_both_sides(b=new_game(), show_move_history=true)
    n_white_pieces = count(i->i=='1', bits(b.white_pieces))
    n_black_pieces = count(i->i=='1', bits(b.black_pieces))
    white_to_move = true
    moves_made = []
    for i in 1:100000
        print("\033[2J")  # clear screen
        height = displaysize(STDOUT)[1]
        print("\033[$(height)A") # up 12 lines
        println()
        printbd(b)

        if show_move_history
            for (j,mm) in enumerate(moves_made)
                if (j-1)%2==0
                    println()
                    print("$(floor(Integer,(j+1)/2)). ")
                end
                print(mm)
                print("  \t")
            end
            println()
        end

        moves = generate_moves(b, white_to_move)
        if length(moves)==0
            break
        end
        print_algebraic(moves)

        # user chooses next move
        println("Please select next move (1-$(length(moves))):")
        r = parse(readline())
        if typeof(r)==Void || r==0 || r>length(moves)
            println("No move selected, quitting.")
            break
        end
        m = moves[r]

        push!(moves_made, algebraic_move(m))
        make_move!(b, m)

        white_to_move = !white_to_move
    end
end

function test_position_1()
    b = Board()

    set!(b, WHITE, ROOK, E, 2)
    set!(b, BLACK, PAWN, E, 5)

    white_to_move = true

    moves = generate_moves(b, white_to_move)
    printbd(b,moves)
    m = moves[11]

    make_move!(b, m)

    printbd(b)
end

function test_position_2()
    b = new_game()
    white_to_move = true
    printbd(b)

    moves = generate_moves(b, white_to_move)
    print_algebraic(moves)
    m = moves[12]  # d4
    print_algebraic(m)
    make_move!(b, m)
    printbd(b)

    moves = generate_moves(b, !white_to_move)
    print_algebraic(moves)
    m = moves[10]  # e5
    print_algebraic(m)
    make_move!(b, m)
    printbd(b)

    moves = generate_moves(b, white_to_move)
    print_algebraic(moves)
    m = moves[29]  # d4
    print_algebraic(m)
    make_move!(b, m)
    printbd(b)

    moves = generate_moves(b, !white_to_move)
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
    printbd(b)
    moves = generate_moves(b,true)
    print_algebraic(moves)
end

function test_enpassant()
    # https://github.com/official-stockfish/Stockfish
    b = Board()
    set!(b, WHITE, PAWN, D, 2)
    set!(b, BLACK, PAWN, C, 4)
    set!(b, BLACK, PAWN, E, 4)
    printbd(b)

    moves = generate_moves(b, true)
    print_algebraic(moves)
    make_move!(b,moves[2])
    printbd(b)

    moves = generate_moves(b, false, moves[2].sqr_dest)
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

    printbd(b)
    moves = generate_moves(b, true)
    print_algebraic(moves)
    m = moves[17]
    print_algebraic(m)

    make_move!(b, m)
    printbd(b)
    moves = generate_moves(b, true)
    print_algebraic(moves)
    m = moves[5]
    print_algebraic(m)

    make_move!(b, m)
    printbd(b)
    moves = generate_moves(b, true)
    print_algebraic(moves)
end

function test_king_moves()
    b = Board()
    set!(b, WHITE, KING, E, 5)
    set!(b, BLACK, ROOK, D, 8)
    set!(b, BLACK, ROOK, F, 8)
    set!(b, BLACK, ROOK, A, 6)
    set!(b, BLACK, ROOK, A, 4)

    b.castling_rights = 0x00
    b.last_move_pawn_double_push = square(C, 5)
    printbd(b)

    moves = generate_moves(b, true)
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

    b.castling_rights = 0x00
    b.last_move_pawn_double_push = square(C, 5)
    printbd(b)

    moves = generate_moves(b, true)
    print_algebraic(moves)
end

function test_fen()
    for (name,fen) in perft_fens
        println("$name $fen")
        b, white_to_move = read_fen(fen)
        printbd(b)
        for i in 1:3
            tic()
            nodes = perft(b, i, white_to_move)
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
    printbd(b)
    moves = generate_moves(b,true)
    print_algebraic(moves)
    make_move!(b, moves[1])
    printbd(b)
end

function test_position_7()
    b, white_to_move = read_fen(perft_fens[4][2])
    printbd(b)
    moves = generate_moves(b,white_to_move)
    print_algebraic(moves)
end

function test_position_8()
    b, white_to_move = read_fen(perft_fens[3][2])
    printbd(b)
    moves = generate_moves(b,white_to_move)
    print_algebraic(moves)
    println("================================================")
    println("================================================")
    for m in moves
        println()
        println()
        test_board = deepcopy(b)
        make_move!(test_board, m)
        printbd(test_board)
        reply_moves = generate_moves(test_board, !white_to_move)
        print_algebraic(reply_moves)
    end
end

function test_position_9()
    b, white_to_move = read_fen(perft_fens[6][2])
    printbd(b)
    moves = generate_moves(b,white_to_move)
    print_algebraic(moves)
    println("================================================")
    println("================================================")
    for m in moves
        println()
        println()
        print_algebraic(m)
        test_board = deepcopy(b)
        make_move!(test_board, m)
        printbd(test_board)
        reply_moves = generate_moves(test_board, !white_to_move)
        print_algebraic(reply_moves)
        @show length(reply_moves)
    end
end



test_position_9()

end
