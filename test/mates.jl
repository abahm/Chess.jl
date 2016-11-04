# mates.jl

function test_mate_in_one()
    b = read_fen("8/8/8/8/8/7k/6rr/K7 b  -")
    printbd(b)
    for i in 1:7
        tic()
        nodes = perft(b, i)
        t = toq()
        println("$i   $nodes nodes  $(round(t,4)) s  $(round(nodes/(t*1000),2)) kn/s")
    end
    println()
    println()
end

test_mate_in_one()
