# xboard.jl  - comms tester

file_io = "xboard.txt"
if isfile(file_io)
    rm(file_io)
end
function xboard_readline()
    flush(STDIN)
    r = readline()

    io = open(file_io, "a")
    print(io, r)
    close(io)

    r
end
function xboard_writeline(msg::String)
    nchar = write(STDOUT, String(msg*"\n"))
    flush(STDOUT)

    io = open(file_io, "a")
    print(io, "\t\t\t\t\t$nchar\t $msg\n")
    close(io)
end


xboard_readline() # xboard
xboard_readline() # protover 2
xboard_writeline("")
xboard_writeline("feature usermove=1")
xboard_readline()
xboard_writeline("feature done=1")
xboard_readline()




xboard_readline() # new
xboard_readline() # random
xboard_readline() # level 40 5 0
xboard_readline() # post
xboard_readline() # hard
xboard_readline() # time 30000
xboard_readline() # otim 30000
xboard_readline() # usermove ....

xboard_writeline("move a7a6")

xboard_readline() # time 29990
xboard_readline() # otim 29851
xboard_readline() # usermove ....

xboard_writeline("move b7b6")

xboard_readline() # time
xboard_readline() # otim
xboard_readline() # usermove ....

xboard_writeline("move c7c6")

xboard_readline() # time
xboard_readline() # otim
xboard_readline() # usermove ....

xboard_writeline("move d7d6")

xboard_readline() # time 30000
xboard_readline() # otim 30000
xboard_readline() # usermove



xboard_readline()
