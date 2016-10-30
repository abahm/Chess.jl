# search.jl


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

function negaMax(board, depth)
    if depth == 0
        return (board.side_to_move==WHITE?1:-1)*evaluate(board), Move[], 1
    end
    max_value = -Inf
    max_move = nothing
    principal_variation = Move[]
    number_nodes_visited = 0
    for m in generate_moves(board)
        test_board = deepcopy(board)
        make_move!(test_board, m)
        score, pv, nnodes = negaMax(test_board, depth - 1 )
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


function best_move_alphabeta(time_allowed_centiseconds::UInt64)
    moves = generate_moves(board)

    best_value = -Inf
    best_move = nothing
    minmax = board.side_to_move==WHITE?1:-1
    #minmax *= (depth%2==0?1:-1)
    for m in moves
        test_board = deepcopy(board)
        make_move!(test_board, m)

        value = minmax*αβMax(test_board, -Inf, Inf, depth)
        #@show value, algebraic_move(m)
        if best_value < value
            best_value = value
            best_move = m
        end
    end

    best_move
end

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
