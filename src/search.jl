# search.jl


"""
Find best move by negamax algorithm, returns:
    score, best move, principal variation,
    number of nodes visited, time in seconds
"""
function best_move_negamax(board, depth)
    tic()
    moves = generate_moves(board)

    best_value = -Inf
    best_move = nothing
    principal_variation = Move[]
    number_nodes_visited = 0
    for m in moves
        test_board = deepcopy(board)
        make_move!(test_board, m)

        value, pv, nnodes = negaMax(test_board, depth)
        value *= -1
        #@show value, algebraic_move(m)
        if best_value < value
            best_value = value
            best_move = m
            principal_variation = pv
        end
        number_nodes_visited += nnodes
    end
    reverse!(principal_variation)
    best_value, best_move, principal_variation, number_nodes_visited, toq()
end

"Called only by best_move_negamax"
function negaMax(board, depth)
    if depth == 0
        return (board.side_to_move==WHITE?1:-1)*evaluate(board), Move[], 1
    end
    max_value = -Inf
    max_move = nothing
    principal_variation = Move[]
    number_nodes_visited = 0
    #prior_castling_rights = board.castling_rights
    #prior_last_move_pawn_double_push = board.last_move_pawn_double_push
    for m in generate_moves(board)
        test_board = deepcopy(board)
        make_move!(test_board, m)
        score, pv, nnodes = negaMax(test_board, depth - 1 )
        #make_move!(board, m)
        #score, pv, nnodes = negaMax(board, depth - 1 )
        #unmake_move!(board, m, board.castling_rights, board.last_move_pawn_double_push)
        score *= -1
        if( score > max_value )
            max_value = score
            max_move = m
            principal_variation = pv
        end
        number_nodes_visited += nnodes
    end

    if max_move == nothing
        # no moves available - it is either a draw or a mate
        if is_king_in_check(board)
            max_value = MATE_SCORE + depth  # add depth to define mate in N moves
        else
            max_value = DRAW_SCORE
        end
    else
        push!(principal_variation, max_move)
    end
    max_value, principal_variation, number_nodes_visited
end


"Find best move by alpha-beta algorithm"
function best_move_alphabeta()
    moves = generate_moves(board)

    best_value = -Inf
    best_move = nothing
    multiplier = board.side_to_move==WHITE?1:-1
    #multiplier *= (depth%2==0?1:-1)
    for m in moves
        test_board = deepcopy(board)
        make_move!(test_board, m)

        value = multiplier*αβMax(test_board, -Inf, Inf, depth)
        #@show value, algebraic_move(m)
        if best_value < value
            best_value = value
            best_move = m
        end
    end

    best_move
end

"Called only by best_move_alphabeta"
function αβMax(board, α, β, depthleft)

    if depthleft == 0
        return evaluate(board)
    end

    for m in generate_moves(board)
        test_board = deepcopy(board)
        make_move!(test_board, m)

        score = αβMin( test_board, α, β, depthleft - 1 )
        if( score >= β )
            return β   # fail hard β-cutoff
        end
        if( score > α )
            α = score # α acts like max in MiniMax
        end
    end

    α
end

"Called only by best_move_alphabeta"
function αβMin(board, α, β, depthleft)

    if ( depthleft == 0 )
        return -evaluate(board)
    end

    for m in generate_moves(board)
        test_board = deepcopy(board)
        make_move!(test_board, m)

        score = αβMax( test_board, α, β, depthleft - 1 )
        if( score <= α )
            return α # fail hard α-cutoff
        end
        if( score < β )
            β = score # β acts like min in MiniMax
        end
    end

    β
end
