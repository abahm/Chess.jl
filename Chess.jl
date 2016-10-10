# chess.jl

module Chess

export perft, new_game

include("board.jl")
include("move.jl")



function perft(b::Board, levels::Integer, white_to_move::Bool=true)
    moves = generate_moves(b, white_to_move)
    if levels==1
        #print_algebraic(moves, b)
        return length(moves)
    end

    cnt = 0
    saved_b = deepcopy(b)
    for m in moves
        #print_algebraic(m,b)
        make_move!(b, m)
        cnt = cnt + perft(b, levels-1, !white_to_move)
        b = deepcopy(saved_b)
    end
    return cnt
end

function test_position()
    b = Board(0,0,0,0,0,0,0,0,true,true)

    #set!(b, WHITE, ROOK, E, 2)
    #set!(b, WHITE, PAWN, E, 4)
    #set!(b, BLACK, PAWN, B, 2)
    #set!(b, BLACK, KING, H, 8)

    #set!(b, WHITE, PAWN, E, 4)
    #set!(b, BLACK, PAWN, E, 5)
    #set!(b, BLACK, PAWN, F, 5)
    #set!(b, BLACK, PAWN, A, 6)
    #set!(b, WHITE, ROOK, D, 3)
    #set!(b, WHITE, BISHOP, G, 6)

    #set!(b, WHITE, KNIGHT, B, 1)
    set!(b, WHITE, KNIGHT, E, 5)

    #printbd(b)

    b
end

function play_both_sides(b, nmoves)
    #srand(0)
    white_to_move = true
    moves_made = Move[]
    for i in 1:nmoves
        print("\033[2J")  # clear
        print("\033[11A") # up 12 lines
        printbd(b)
        println("")
        #print_algebraic(moves_made,b)
        moves = generate_moves(b, white_to_move)
        if length(moves)==0
            break
        end
        m = moves[rand(1:length(moves))]
        #mn = ceil(Integer, (i)/2)
        #println("$mn " * (white_to_move?"":"... ") * algebraic_move(m,b) * "  ")
        #println("")
        make_move!(b, m)
        push!(moves_made,m)
        white_to_move = !white_to_move
        sleep(0.1)
    end
end

function play_self()
    play_both_sides(new_game(), 1000)
end

function test_position_1()
    b = Board(0,0,0,0,0,0,0,0,true,true)

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
    print_algebraic(moves, b)
    m = moves[12]  # d4
    print_algebraic(m, b)
    make_move!(b, m)
    printbd(b)

    moves = generate_moves(b, !white_to_move)
    print_algebraic(moves, b)
    m = moves[10]  # e5
    print_algebraic(m, b)
    make_move!(b, m)
    printbd(b)

    moves = generate_moves(b, white_to_move)
    print_algebraic(moves, b)
    m = moves[29]  # d4
    print_algebraic(m, b)
    make_move!(b, m)
    printbd(b)

    moves = generate_moves(b, !white_to_move)
    print_algebraic(moves, b)
    m = moves[10]  # d4
    print_algebraic(m, b)
    make_move!(b, m)
    printbd(b)
end

function test_position_3()

    b = Board(0,0,0,0,0,0,0,0,true,true)

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
    b = Board(0,0,0,0,0,0,0,0,true,true)
    set!(b, WHITE, PAWN, A, 5)
    set!(b, BLACK, PAWN, H, 5)
    printbd(b)
    moves = generate_moves(b,true)
    print_algebraic(moves, b)
end

function perft()
    # run through all the first 1,2,3,4,5,6,7 moves
    # https://chessprogramming.wikispaces.com/Perft+Results
    for i in 1:4
        println("$i   $(perft(new_game(), i))")
    end
end

function test_enpassant()
    # https://github.com/official-stockfish/Stockfish
    b = Board(0,0,0,0,0,0,0,0,true,true)
    set!(b, WHITE, PAWN, D, 2)
    set!(b, BLACK, PAWN, C, 4)
    set!(b, BLACK, PAWN, E, 4)
    printbd(b)

    moves = generate_moves(b, true)
    print_algebraic(moves, b)
    make_move!(b,moves[2])
    printbd(b)

    moves = generate_moves(b, false, moves[2].sqr_dest)
    print_algebraic(moves, b)
    make_move!(b,moves[2])
    printbd(b)
end



play_self()


end
