
"""
ZobristHash()

Initialize a two dimensional hash (e.g. chessboard state)

# Members
```
	seed::UInt32
	H::Array{UInt64,2}
```

# Methods

  * ZobristHash()
  * ZobristHash(seed)
    + Will seed the RNG for debugging purposes

# Return
  * A randomly initialized two dimensional Hash
"""
type ZobristHash
	seed::UInt32
	H::Array{UInt64,2}
	ZobristHash()     = init_zobrist_hash!(new())
	ZobristHash(seed) = init_zobrist_hash!(new(), seed)
end

"""
init_zobrist_hash!()
Create a default 12 x 64 Zobrist Hash

# Arguments
  * x::ZobristHash
# Return
  * An initialized hash array
"""
function init_zobrist_hash!(x::ZobristHash)
	x.H = Array{UInt64}(12,64)
	rng = MersenneTwister()

	# Initialize random array
	for a in eachindex(x.H)
		x.H[a] = rand(rng, UInt64)
	end

	return x
end

"""
init_zobrist_hash!(random_seed)

# Arguments
  * x::ZobristHash
  * `seed::UInt32`: Initialize the RNG with a seed

# Return
  * An initialized ZobristHash
"""
function init_zobrist_hash!(x::ZobristHash, seed::UInt32)
  	x.seed      = seed
	x.H         = Array{UInt64}(12, 64)
	rng         = MersenneTwister(x.seed)

	# Initialize random array
	for a in eachindex(x.H)
		x.H[a] = rand(rng, UInt64)
	end

	return x
end



@inline function update_zobrist(x::ZobristHash, v::UInt64, piece::UInt8, position::UInt8)
	x.H[piece, position] $ v
end
