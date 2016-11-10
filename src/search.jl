# search.jl

"""
Find best move, returns:
    score, best move, principal variation,
    number of nodes visited, time in seconds
"""
function best_move_search(board, depth)
    #best_move_negamax(board, depth)
    best_move_alphabeta(board, depth)
end

function best_move_negamax(board, depth)
    tic()
    moves = generate_moves(board)

    best_value = -Inf
    best_move = nothing
    principal_variation = Move[]
    number_nodes_visited = 0
    prior_castling_rights = board.castling_rights
    prior_last_move_pawn_double_push = board.last_move_pawn_double_push
    for m in moves
        make_move!(board, m)
        value, pv, nnodes = negaMax(board, depth)
        value *= -1
        if best_value < value
            best_value = value
            best_move = m
            principal_variation = pv
        end
        number_nodes_visited += nnodes

        unmake_move!(board, m, prior_castling_rights, prior_last_move_pawn_double_push)
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
    prior_castling_rights = board.castling_rights
    prior_last_move_pawn_double_push = board.last_move_pawn_double_push
    for m in generate_moves(board)
        make_move!(board, m)
        score, pv, nnodes = negaMax(board, depth - 1 )
        unmake_move!(board, m, prior_castling_rights, prior_last_move_pawn_double_push)
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
function best_move_alphabeta(board, depth)
    tic()
    moves = generate_moves(board)

    best_value = -Inf
    best_move = nothing
    principal_variation = Move[]
    number_nodes_visited = 0
    prior_castling_rights = board.castling_rights
    prior_last_move_pawn_double_push = board.last_move_pawn_double_push
    for m in moves
        make_move!(board, m)
        score, pv, nnodes = αβMax(board, -Inf, Inf, depth)
        score *= -1
        if best_value < score
            best_value = score
            best_move = m
            principal_variation = pv
        end
        number_nodes_visited += nnodes

        unmake_move!(board, m, prior_castling_rights, prior_last_move_pawn_double_push)
    end

    reverse!(principal_variation)
    best_value, best_move, principal_variation, number_nodes_visited, toq()
end

"Called only by best_move_alphabeta"
function αβMax(board, α, β, depth)
    if depth == 0
        return (board.side_to_move==WHITE?1:-1)*evaluate(board), Move[], 1
    end

    max_move = nothing
    principal_variation = Move[]
    number_nodes_visited = 0
    prior_castling_rights = board.castling_rights
    prior_last_move_pawn_double_push = board.last_move_pawn_double_push
    for m in generate_moves(board)
        make_move!(board, m)
        score, pv, nnodes = αβMin( board, α, β, depth - 1 )
        unmake_move!(board, m, prior_castling_rights, prior_last_move_pawn_double_push)
        if( score >= β )
            return β, principal_variation, number_nodes_visited   # fail hard β-cutoff
        end
        if( score > α )
            α = score # α acts like max in MiniMax
            max_move = m
            principal_variation = pv
        end
        number_nodes_visited += nnodes
    end

    if max_move == nothing
        # no legal moves available - it is either a draw or a mate
        if is_king_in_check(board)
            α = MATE_SCORE + depth  # add depth to define mate in N moves
        else
            α = DRAW_SCORE
        end
    else
        push!(principal_variation, max_move)
    end

    α, principal_variation, number_nodes_visited
end

"Called only by best_move_alphabeta"
function αβMin(board, α, β, depth)
    if ( depth == 0 )
        return (board.side_to_move==WHITE?1:-1)*evaluate(board), Move[], 1
    end

    max_move = nothing
    principal_variation = Move[]
    number_nodes_visited = 0
    prior_castling_rights = board.castling_rights
    prior_last_move_pawn_double_push = board.last_move_pawn_double_push
    for m in generate_moves(board)
        make_move!(board, m)
        score, pv, nnodes =  αβMax( board, α, β, depth - 1 )
        unmake_move!(board, m, prior_castling_rights, prior_last_move_pawn_double_push)
        if( score <= α )
            return α, principal_variation, number_nodes_visited # fail hard α-cutoff
        end
        if( score < β )
            β = score # β acts like min in MiniMax
            max_move = m
            principal_variation = pv
        end
        number_nodes_visited += nnodes
    end

    if max_move == nothing
        # no legal moves available - it is either a draw or a mate
        if is_king_in_check(board)
            β = MATE_SCORE + depth  # add depth to define mate in N moves
        else
            β = DRAW_SCORE
        end
    else
        push!(principal_variation, max_move)
    end

    β, principal_variation, number_nodes_visited
end
