# xboard.jl - protocol

function xboard_readline()
    r = readline()
    #=
    io = open("Chess.readline.txt", "a")
    print(io, r)
    close(io)
    =#
    r
end
function xboard_writeline(msg::String)
    nchar = write(STDOUT, String(msg*"\n"))
    flush(STDOUT)
    #=
    io = open("Chess.writeline.txt", "a")
    print(io, "$nchar\t$msg\n")
    close(io)
    =#
end
function xboard_loop()
    chess_engine_debug_mode = true
    chess_engine_show_thinking = true
    my_time = Inf
    opp_time = Inf
    ply = 2

    board = new_game()
    while true
        r = xboard_readline()
        tokens = split(r)

        if "xboard" ∈ tokens
            xboard_writeline("")
        end

        if "protover" ∈ tokens
            xboard_writeline("tellics say     $version")
            xboard_writeline("tellics say     by $author")
            xboard_writeline("feature myname=\"$(version)\"")
            xboard_readline()
            # request xboard send moves to the engine with the command "usermove MOVE"
            xboard_writeline("feature usermove=1")
            xboard_readline()
            # use the protocol's new "setboard" command to set up positions
            xboard_writeline("feature setboard=1")
            xboard_readline()
            # tell xboard we are not gnuchess (section 8 of ref), don't kill us
            xboard_writeline("feature sigint=0")
            xboard_readline()
            # allow xboard to synchronize with us
            xboard_writeline("feature ping=1")
            xboard_readline()
            # don't use obsolete "colors" command
            xboard_writeline("feature colors=0")
            xboard_readline()
            # specify options that we can change in the user interface
            xboard_writeline("feature option=\"Depth -spin $ply 0 4\"")
            xboard_readline()
            # done sending commands
            xboard_writeline("feature done=1")
            xboard_readline()
        end

        if "new" ∈ tokens
            board = new_game()
        end

        if "quit" ∈ tokens
            quit() # the julia REPL
        end

        if "post" ∈ tokens
            chess_engine_show_thinking = true
        end

        if "ping" ∈ tokens
            xboard_writeline("pong $(tokens[2])")
        end

        if "nopost" ∈ tokens
            chess_engine_show_thinking = false
        end

        if "time" ∈ tokens
            my_time = parse(tokens[2])
        end

        if "otim" ∈ tokens
            opp_time = parse(tokens[2])
        end

        if "go" ∈ tokens
            # send xboard reply move
            best_value, best_move, pv, nodes, time_s = best_move_negamax(board, ply)
            if chess_engine_show_thinking
                score = evaluate(board)
                xboard_writeline("\t $ply\t $score\t $time_s\t $nodes\t $(long_algebraic_move(pv))")
            end
            if best_move!=nothing
                bestmovestr = long_algebraic_move(best_move)
                xboard_writeline("move $bestmovestr")
                make_move!(board, best_move)
            end
        end

        if "usermove" ∈ tokens
            # translate and make user's move
            movestr = tokens[2]
            moves = generate_moves(board)
            for m in moves
                if long_algebraic_move(m)==movestr
                    make_move!(board,m)
                    break
                end
            end

            # think of best reply
            score, best_move, pv, nodes, time_s = best_move_negamax(board, ply)
            if chess_engine_show_thinking
                xboard_writeline("\t $ply\t $score\t $time_s\t $nodes\t $(long_algebraic_move(pv))")
            end
            if best_move!=nothing
                bestmovestr = long_algebraic_move(best_move)
                xboard_writeline("move $bestmovestr")
                make_move!(board, best_move)
            end
        end

        if "option" ∈ tokens
            if startswith(tokens[2], "Depth=")
                ply = parse(tokens[2][7:end])
            end
        end
    end
end
