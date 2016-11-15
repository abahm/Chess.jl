module Zobrist

export ZobristHash , same_zobrist, update_zobrist, copy_zobrist

"""
ZobristHash()

Initialize a two dimensional hash (e.g. chessboard state)

# Members
```
	pieces::UInt16
	positions::UInt16
	seed::UInt32
	H::Array{UInt64,2}
```

# Methods

  * ZobristHash()                             
  * ZobristHash(numpieces, numpositions)      
  * ZobristHash(seed, numpieces, numpositions)
    + Will seed the RNG for debugging purposes

# Return 
  * A randomly initialized two dimensional Hash
"""
type ZobristHash
	pieces::UInt16
	positions::UInt16
	seed::UInt32
	H::Array{UInt64,2}
	ZobristHash()                              = init_zobrist_hash(new())
	ZobristHash(numpieces, numpositions)       = init_zobrist_hash(new(), numpieces,numpositions)
	ZobristHash(seed, numpieces, numpositions) = init_zobrist_hash(new(), seed, numpieces, numpositions)
end

"""
init_zobrist_hash()
Create a default 12 x 64 Zobrist Hash

# Arguments
  * x::ZobristHash
# Return 
  * An initialized hash array 
"""
function init_zobrist_hash(x::ZobristHash)
	x.pieces    = 12
	x.positions = 64
	x.H         = Array{UInt64}(x.pieces,x.positions)

	rng         = MersenneTwister()

	# Initialize random array
	for a in eachindex(x.H)
		x.H[a] = rand(rng, UInt64)
	end

	return x
end

"""
# Arguments
  * x::ZobristHash
  * [`num_pieces::UInt16`: Number of pieces (Default=12)]
  * [`num_positions::UInt16`: Number of positions for a piece (Default=64)]

# Return 
  * An initialized ZobristHash
"""
function init_zobrist_hash(x::ZobristHash, num_pieces::UInt16, num_positions::UInt16)
	x.pieces    = num_pieces
	x.positions = num_positions
	x.H         = Array{UInt64}(x.pieces,x.positions)

	rng         = MersenneTwister()

	# Initialize random array
	for a in eachindex(x.H)
		x.H[a] = rand(rng, UInt64)
	end

	return x
end

"""
init_zobrist_hash(random_seed, num_pieces=12, num_positions=64 )

# Arguments
  * x::ZobristHash
  * `seed::UInt32`: Initialize the RNG with a seed
  * [`num_pieces::UInt16`: Number of pieces (Default=12)]
  * [`num_positions::UInt16`: Number of positions for a piece (Default=64)]

# Return 
  * An initialized ZobristHash
"""
function init_zobrist_hash(x::ZobristHash, seed::UInt32, num_pieces::UInt16, num_positions::UInt16)
  	x.seed      = seed
	x.pieces    = num_pieces
	x.positions = num_positions
	x.H         = Array{UInt64}(x.pieces,x.positions)

	rng         = MersenneTwister(x.seed)

	# Initialize random array
	for a in eachindex(x.H)
		x.H[a] = rand(rng, UInt64)
	end

	return x
end

"""
copy_zobrist(dst::ZobristHash,src::ZobristHash)

deep copy all members of src to dst

# Return
  * True if copy successful
  * False otherwise

"""
function copy_zobrist(dst::ZobristHash,src::ZobristHash)
	if size(dst.H) != size(src.H)
		return false
	end
	dst.pieces     = src.pieces
	dst.positions  = src.positions
	dst.seed       = src.seed
	dst.H          = deepcopy(src.H)

	return true
end


"""
same_zobrist(x::ZobristHash,y::ZobristHash)

**Compare two hash arrays entry by entry** 

# Return
  * True if both hashes have same entries at same indices
  * False otherwise

"""
function same_zobrist(x::ZobristHash,y::ZobristHash)
	if size(x.H) != size(y.H)
		return false
	end
	if x.pieces != y.pieces
		return false
	end
	if x.positions != y.positions
		return false
	end
	if x.seed != y.seed
		return false
	end

	# Compare entries
	for a in eachindex(x.H)
		if x.H[a] != y.H[a]
			return false
		end
	end

	return true
end

"""
update_zobrist(x::ZobristHash, v::UInt64, xcoord::UInt16, ycoord::UInt16)

Inplace update of a ZobristHash.

# Arguments
  * x::ZobristHash
  * v::UInt64: New value to hash
  * xcoord::UInt16
  * ycoord::UInt16

"""
function update_zobrist(x::ZobristHash, v::UInt64, xcoord::UInt16, ycoord::UInt16)
	x.H[xcoord, ycoord] = x.H[xcoord, ycoord] $ v 
	return x.H[xcoord, ycoord]
end




end

