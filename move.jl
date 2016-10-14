# move.jl


# allows for move
type Move
    sqr_src::UInt64
    sqr_dest::UInt64
    sqr_ep::UInt64
    promotion_to::Integer
    castling::UInt8
end
Move(src, dest) = Move(src, dest, UInt64(0), NONE, UInt8(0))
Move(src, dest, cstl) = Move(src, dest, UInt64(0), NONE, cstl)
Move(src, dest, ep, promote) = Move(src, dest, ep, promote, UInt8(0))
