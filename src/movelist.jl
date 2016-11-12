# movelist.jl

const MAX_MOVES_LENGTH = 100
const MAX_MOVES_DEPTH = 100

type Movelist
    moves::Array{Move, 2}
    position::UInt8
    depth::UInt8
end
