# chess.jl

function perft(b::Board, levels::Integer)
    moves = generate_moves(b)
    if levels<=1
        return length(moves)
    end

    count = 0
    for m in moves
        test_board = deepcopy(b)
        make_move!(test_board, m)
        count = count + perft(test_board, levels-1)
    end
    return count
end

function random_play_both_sides(seed, show_move_history, delay=0.001, b=new_game(), max_number_of_moves=1000)
    srand(seed)
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

        moves = generate_moves(b)
        if length(moves)==0
            break
        end
        #print_algebraic(moves)
        r = rand(1:length(moves))
        m = moves[r]

        make_move!(b, m)
        push!(move_history, m)

        sleep(delay)
    end
end

function random_play_both_sides(n)
    for random_seed in 1:n
        random_play_both_sides(random_seed, true, 0.1)
    end
end

function user_play_both_sides(b=new_game(), show_move_history=true)
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

        moves = generate_moves(b)
        if length(moves)==0
            break
        end
        print_algebraic(moves)

        # user chooses next move
        println("Please select next move (1-$(length(moves))) (or divide [n] or debug):")
        r = readline()
        if startswith(r, "divide")
            levels = parse(split(r)[2])-1
            total_count = 0
            for m in moves
                test_board = deepcopy(b)
                make_move!(test_board, m)
                count = perft(test_board, levels)
                total_count += count
                println("$m $count")
            end
            println("Nodes: $total_count")
            println("Moves: $(length(moves))")
            break
        end
        if startswith(r, "debug")
            @show b
            break
        end
        mv = parse(r)
        if typeof(mv)==Void || mv==0 || mv>length(moves)
            println("No move selected, quitting.")
            break
        end
        m = moves[mv]

        push!(moves_made, algebraic_move(m))
        make_move!(b, m)
    end
end

function best_play_both_sides(show_move_history = true, delay=1.0, b=new_game(), max_number_of_moves=100)
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

        moves = generate_moves(b)
        if length(moves)==0
            break
        end

        multiplier = (b.side_to_move==WHITE ? 1 : -1)
        best_value = -Inf
        best_move = nothing
        for m in moves
            test_board = deepcopy(b)
            make_move!(test_board, m)
            value = multiplier*evaluate(test_board)
            if best_value < value
                best_value = value
                best_move = m
            end
        end

        make_move!(b, best_move)
        push!(move_history, best_move)

        sleep(delay)
    end
end
