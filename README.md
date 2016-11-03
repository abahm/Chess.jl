<a name="logo"/>
<div align="center">
<img src="docs/JuliaChess.png" alt="Julia Logo" width="210"></img>
</a>
</div>


<a name="Chess-Engine-in-Julia"/>


# Chess.jl

Julia module that plays chess, and [chess960](https://en.wikipedia.org/wiki/Chess960).   To run this program, you must install [Julia](http://julialang.org/), run it from the github cloned directory, and do `include("Chess.jl")` to run the game loop.   The chess board and move history is printed in the [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop).

The goal is to create a reasonably performant chess engine, that can generate legal moves, and play with minimal interface (i.e. in the REPL).   

Bitboards are used to represent the state.   This code is a learning exercise for me in both engine building, and performant Julia code.



## Running with winboard/xboard

In Linux/Max OSX:
`xboard -fcp 'julia Chess.jl -xboard'`

In windows:
`winboard.exe /debug /fcp="julia Chess.jl -xboard"`





## Resources

[Resources](docs/Resources.md)




## History

[History](docs/README.md)
