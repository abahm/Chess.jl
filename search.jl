# search.jl

function negaMax(board, depth::UInt8)
    if depth == 0
        return evaluate(board)
    end
    max = Inf
    for m in generate_moves(board)
        test_board = deepcopy(board)
        make_move!(test_board, m)

        score = -negaMax( depth - 1 )
        if( score > max )
            max = score
        end
    end

    max
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

# call by    score = αβMax(-Inf, Inf, depth)
