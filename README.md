<a name="logo"/>
<div align="center">
<img src="docs/JuliaChess.png" alt="Julia Logo" width="210"></img>
</a>
</div>


<a name="Chess-Engine-in-Julia"/>


# Chess.jl

[Julia](http://julialang.org/) module which can play chess and [chess960](https://en.wikipedia.org/wiki/Chess960).   

The goal is to create a reasonably performant chess engine, that can generate legal moves, and play with minimal interface (i.e. in the REPL).   Bitboards are used to represent the state.   This code is a learning exercise in both engine building, and performant Julia code, and is still "in progress".



## Playing a game in the REPL
`julia Chess.jl -repl`

The chess board and move history is printed every move in the  [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop).  Enter moves as "e2e4" or "h7h8q".  Type "?" to see a full list of commands.




## Play a game with winboard/xboard

In Linux/Max OSX:
`xboard -fcp 'julia Chess.jl -xboard'`

In windows:
`winboard.exe /debug /fcp="julia Chess.jl -xboard"`



## Developers
As it is during development, to load the module, you will have to add the path to your
.juliarc.jl in your home directory:

`] add "<path-to-local-repo>/Chess.jl"`

Start julia (v0.7 or higher), then execute

`using Chess`

`Chess.play()`


## Resources

[Resources](docs/Resources.md)




## History

[History](docs/README.md)
