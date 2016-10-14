# chess.jl

module Chess

#export perft, new_game

include("board.jl")
include("move.jl")



function perft(b::Board, levels::Integer, white_to_move::Bool=true)
    moves = generate_moves(b, white_to_move)
    if levels==1
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

function random_play_both_sides(b=new_game(), nmoves=1000, show_move_history=true)
    srand(4)
    n_white_pieces = count(i->i=='1', bits(b.white_pieces))
    n_black_pieces = count(i->i=='1', bits(b.black_pieces))
    white_to_move = true
    moves_made = []
    for i in 1:nmoves
        #print("\033[2J")  # clear
        #print("\033[11A") # up 12 lines
        #println()
        println()
        printbd(b)

        #println(" #w $(count(i->i=='1', bits(b.white_pieces)))  #b $(count(i->i=='1', bits(b.black_pieces)))")

        if show_move_history
            for (j,mm) in enumerate(moves_made)
                if (j-1)%2==0
                    println()
                    print("$(floor(Integer,(j+1)/2)). ")
                end
                print(mm)
                print(" \t")
            end
            println()
        end

        # validation
        #@assert n_white_pieces >= count(i->i=='1', bits(b.white_pieces))
        #n_white_pieces = count(i->i=='1', bits(b.white_pieces))
        #@assert n_black_pieces >= count(i->i=='1', bits(b.black_pieces))
        #n_black_pieces = count(i->i=='1', bits(b.black_pieces))

        #print_algebraic(moves_made,b)
        moves = generate_moves(b, white_to_move)
        if length(moves)==0
            break
        end
        #print_algebraic(moves,b)
        r = rand(1:length(moves))
        m = moves[r]

        push!(moves_made, algebraic_move(m,b))
        #mn = ceil(Integer, (i)/2)
        #println("$mn " * (white_to_move?"":"... ") * algebraic_move(m,b) * "  ")
        #println()
        make_move!(b, m)

        white_to_move = !white_to_move
        sleep(0.001)
    end
end

function user_play_both_sides(b=new_game())
    n_white_pieces = count(i->i=='1', bits(b.white_pieces))
    n_black_pieces = count(i->i=='1', bits(b.black_pieces))
    white_to_move = true
    moves_made = []
    for i in 1:100000
        #print("\033[2J")  # clear
        #print("\033[11A") # up 12 lines
        #println()
        println()
        printbd(b)

        #println(" #w $(count(i->i=='1', bits(b.white_pieces)))  #b $(count(i->i=='1', bits(b.black_pieces)))")

        if true
            for (j,mm) in enumerate(moves_made)
                if (j-1)%2==0
                    println()
                    print("$(floor(Integer,(j+1)/2)). ")
                end
                print(mm)
                print(" \t")
            end
            println()
        end

        # validation
        #@assert n_white_pieces >= count(i->i=='1', bits(b.white_pieces))
        #n_white_pieces = count(i->i=='1', bits(b.white_pieces))
        #@assert n_black_pieces >= count(i->i=='1', bits(b.black_pieces))
        #n_black_pieces = count(i->i=='1', bits(b.black_pieces))

        #print_algebraic(moves_made,b)
        moves = generate_moves(b, white_to_move)
        if length(moves)==0
            break
        end
        print_algebraic(moves,b)

        # user chooses next move
        r = parse(readline())
        if r==0
            break
        end
        m = moves[r]

        push!(moves_made, algebraic_move(m,b))
        #mn = ceil(Integer, (i)/2)
        #println("$mn " * (white_to_move?"":"... ") * algebraic_move(m,b) * "  ")
        #println()
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
    b = Board()
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
    print_algebraic(moves,b)
    m = moves[17]
    print_algebraic(m,b)

    make_move!(b, m)
    printbd(b)
    moves = generate_moves(b, true)
    print_algebraic(moves,b)
    m = moves[5]
    print_algebraic(m,b)

    make_move!(b, m)
    printbd(b)
    moves = generate_moves(b, true)
    print_algebraic(moves,b)


end

#test_castling()

#@show perft(new_game(), 2)
#@assert perft(new_game(), 3) == 8902 "perft 3 gives $(perft(new_game(), 3)) instead of 8092"

#random_play_both_sides()

user_play_both_sides()

end

nothing
