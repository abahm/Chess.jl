# Chess.jl

Julia module that plays chess, and chess360.

The goal is to create a reasonably performant chess engine, that can generate legal moves, and play with minimal interface (i.e. in the REPL).   

Bitboards are used to represent the state.   This code is a learning exercise for me in both engine building, and performant Julia code.



## Resources

[Chess programming](https://chessprogramming.wikispaces.com/)

[Stockfish code](https://github.com/official-stockfish/Stockfish)



## History
2016 October 7 I've gotten piece movement working and displaying.  Still to do are enpassant, promotion, and testing for illegal moves that put the king in check.

![snapshot from Oct 2016](2016-10-08-chess.png)
