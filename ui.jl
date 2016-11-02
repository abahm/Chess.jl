# ui.jl


function perft(board::Board, levels::Integer)
    moves = generate_moves(board)
    if levels<=1
        return length(moves)
    end

    node_count = 0
    for m in moves
        test_board = deepcopy(board)
        make_move!(test_board, m)
        node_count = node_count + perft(test_board, levels-1)
    end
    return node_count
end

function perft_new(board::Board, levels::Integer)
    moves = generate_moves(board)
    if levels<=1
        return length(moves)
    end

    node_count = 0
    prior_castling_rights = board.castling_rights
    prior_last_move_pawn_double_push = board.last_move_pawn_double_push
    for m in moves
        make_move!(board, m)
        node_count = node_count + perft(board, levels-1)
        unmake_move!(board, m, prior_castling_rights, prior_last_move_pawn_double_push)
    end
    return node_count
end

function random_play_both_sides(seed, show_move_history, delay=0.001, b=new_game(), max_number_of_moves=1000)
    srand(seed)
    moves_made = Move[]
    for i in 1:max_number_of_moves
        if show_move_history
            clear_repl()
        end
        println()
        printbd(b)

        if show_move_history
            print_move_history(moves_made)
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
        push!(moves_made, m)

        sleep(delay)
    end
end

function random_play_both_sides(ngames)
    for random_seed in 1:ngames
        random_play_both_sides(random_seed, true, 0.1)
    end
end

function play(depth=0)
    b = new_game()
    moves_made = Move[]
    while true
        clear_repl()
        println()
        printbd(b)
        print_move_history(moves_made)
        println()

        moves = generate_moves(b)
        if length(moves)==0
            if is_king_in_check(b)
                println("Checkmate!")
            else
                println("Drawn game.")
            end
            break
        end

        # user chooses next move
        print("Your move (? for help) ")
        movestr = readline()

        if startswith(movestr,"quit") || movestr=="q\n"
            return
        end

        if startswith(movestr,"go") || movestr=="\n"
            best_value, best_move, pv, number_nodes_visited, time_s = best_move_negamax(b, depth)
            push!(moves_made, best_move)
            make_move!(b, best_move)
            continue
        end

        if startswith(movestr,"undo") || movestr=="u\n"
            if length(moves_made)==0
                continue
            end
            m = pop!(moves_made)
            #unmake_move!(b, m, 0, 0)

            b = new_game()
            for m in moves_made
                make_move!(b, m)
            end

            continue
        end

        if startswith(movestr,"new") || movestr=="n\n"
            b = new_game()
            moves_made = Move[]
            continue
        end

        if startswith(movestr,"fen ")
            fen = movestr[5:end-1]
            @show fen
            b = read_fen(fen)
            moves_made = Move[]
            continue
        end

        if startswith(movestr, "divide")
            levels = parse(split(movestr)[2]) - 1
            total_count = 0
            for m in moves
                test_board = deepcopy(b)
                make_move!(test_board, m)
                node_count = perft(test_board, levels)
                total_count += node_count
                println("$m $node_count")
            end
            println("Nodes: $total_count")
            println("Moves: $(length(moves))")
            println("Press <enter> to continue...")
            readline()
            continue
        end

        if startswith(movestr,"analysis") || movestr=="a\n"
            function search_and_print(ply)
                score,move,pv,nnodes,time_s = best_move_negamax(b, ply)
                # $ply $score $time_s $nodes $pv
                println("$ply\t $(round(score,3))\t $(round(time_s,2))\t $nnodes\t $move\t $(algebraic_move(pv))")
                print("      ")
            end
            for analysis_depth in 0:3
                @time search_and_print(analysis_depth)
            end
            println("Press <enter> to continue...")
            readline()
            continue
        end

        users_move = nothing
        for m in moves
            if startswith(movestr,long_algebraic_move(m))
                users_move = m
                break
            end
        end

        if users_move==nothing
            println(" type your moves like 'e2e4' or 'h7h8q'")
            println(" type 'go' or <enter> to have computer move")
            println(" type 'undo' or 'u' to go back a move")
            println(" type 'fen FEN' to load FEN position")
            println(" type 'analysis' or 'a' to analyze position")
            println(" type 'divide N' count nodes from this position")
            println(" type 'quit' or 'q' to end")
            sleep(2)
            continue
        end

        push!(moves_made, users_move)
        make_move!(b, users_move)

        # make answering move
        best_value, best_move, pv, nodes, time_s = best_move_negamax(b, depth)
        push!(moves_made, best_move)
        make_move!(b, best_move)

    end
end
