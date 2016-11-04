# play.jl

"Print formated move output  1. ♞c3 	♘c6"
function print_move_history(moves::Array{Move,1})
    nmoves = length(moves)
    for (j,move) in enumerate(moves)
        if (j-1)%2==0
            println()
            print("$(floor(Integer,(j+1)/2)). ")
        end
        print(move)
        print(" \t")
    end
end

"Play a random chess game in REPL"
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
        r = rand(1:length(moves))
        m = moves[r]

        make_move!(b, m)
        push!(moves_made, m)

        sleep(delay)
    end
end

"Play N random chess games in REPL"
function random_play_both_sides(ngames)
    for random_seed in 1:ngames
        random_play_both_sides(random_seed, true, 0.1)
    end
end

"Start chess game in REPL"
function repl_loop()
    depth = 2
    board = new_game()
    game_history = []  # store (move, board) every turn
    while true
        clear_repl()
        println()
        printbd(board)
        print_move_history(Move[mb[1] for mb in game_history])
        println()

        moves = generate_moves(board)
        if length(moves)==0
            if is_king_in_check(board)
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
            best_value, best_move, pv, number_nodes_visited, time_s = best_move_negamax(board, depth)
            push!(game_history, (best_move,deepcopy(board)))
            make_move!(board, best_move)
            continue
        end

        if startswith(movestr,"undo") || movestr=="u\n"
            if length(game_history)==0
                continue
            end
            move, prior_board = pop!(game_history)

            # we could just copy the prior_board, but we use this to test unmake_move!()
            unmake_move!(board, move, prior_board.castling_rights,
                                      prior_board.last_move_pawn_double_push)

            continue
        end

        if startswith(movestr,"new") || movestr=="n\n"
            board = new_game()
            game_history = []
            continue
        end

        if startswith(movestr,"fen ")
            fen = movestr[5:end-1]
            @show fen
            board = read_fen(fen)
            game_history = []
            continue
        end

        if startswith(movestr, "divide")
            levels = parse(split(movestr)[2]) - 1
            total_count = 0
            for move in moves
                prior_castling_rights = board.castling_rights
                prior_last_move_pawn_double_push = board.last_move_pawn_double_push
                make_move!(board, move)
                node_count = perft(board, levels)
                unmake_move!(board, move, prior_castling_rights,
                                          prior_last_move_pawn_double_push)

                total_count += node_count
                println("$(long_algebraic_move(move)) $node_count")
            end
            println("Nodes: $total_count")
            println("Moves: $(length(moves))")
            println("Press <enter> to continue...")
            readline()
            continue
        end

        if startswith(movestr, "depth")
            depth = parse(split(movestr)[2])
            println("Depth set to: $depth")
            println("Press <enter> to continue...")
            readline()
            continue
        end

        if startswith(movestr,"analysis") || movestr=="a\n"
            function search_and_print(ply)
                score,move,pv,nnodes,time_s = best_move_negamax(board, ply)
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
        for move in moves
            if startswith(movestr,long_algebraic_move(move))
                users_move = move
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
            println(" type 'depth N' set the plys to look ahead")
            println(" type 'quit' or 'q' to end")
            println()
            println("Press <enter> to continue...")
            readline()
            continue
        end

        push!(game_history, (users_move,deepcopy(board)))
        make_move!(board, users_move)

        # make answering move
        best_value, best_move, pv, nodes, time_s = best_move_negamax(board, depth)
        push!(game_history, (best_move,deepcopy(board)))
        make_move!(board, best_move)
    end   # while true
end

"Start chess game in REPL"
function play()   repl_loop()   end
