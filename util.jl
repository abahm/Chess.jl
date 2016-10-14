# util.jl

function square(c::Integer, r::Integer)
    sqr = UInt64(1) << ((c-1) + 8*(r-1))
    sqr
end

function column_row(sqr::UInt64)
    square_index = Integer(log2(sqr))
    # n.b. ÷ gives integer quotient like div()
    row = (square_index-1)÷8 + 1
    column = ((square_index-1) % 8) + 1
    (column,row)
end
