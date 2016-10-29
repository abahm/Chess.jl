# search.jl


function best_move_negamax(board, depth)
    moves = generate_moves(board)

    best_value = -Inf
    best_move = nothing
    for m in moves
        test_board = deepcopy(board)
        make_move!(test_board, m)

        value = -negaMax(test_board, depth)
        #@show value, algebraic_move(m)
        if best_value < value
            best_value = value
            best_move = m
        end
    end
    best_move
end

function negaMax(board, depth)
    if depth == 0
        return (board.side_to_move==WHITE?1:-1)*evaluate(board)
    end
    max = -Inf
    for m in generate_moves(board)
        test_board = deepcopy(board)
        make_move!(test_board, m)
        score = -negaMax(test_board, depth - 1 )
        if( score > max )
            max = score
        end
    end
    max
end


function best_move_alphabeta(time_allowed_centiseconds::UInt64)
    moves = generate_moves(b)

    best_value = -Inf
    best_move = nothing
    minmax = b.side_to_move==WHITE?1:-1
    #minmax *= (depth%2==0?1:-1)
    for m in moves
        test_board = deepcopy(b)
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
