module day06

using ..InlineTest
using InteractiveUtils
#using ProfileView


#= 
    Part 1
=#

TEST_STRING = """Time:      7  15   30
Distance:  9  40  200"""


function runrace(t::Int, hold::Int)::Int
    time_remaining = t - hold
    if time_remaining <= 0
        return 0
    end
    speed = hold
    distance = time_remaining * speed
    return distance
end

function testallraces(t::Int, r::Int)::Int
    num_wins = 0
    for h = 1:t
        d = runrace(t, h)
        num_wins += (d > r)
    end
    return num_wins
end

function numstring2vec(s::AbstractString)
    # Converts a string of numbers separed by spaces to a Vector{Int}
    s = strip(s) # remove spaces at start/end
    vs = split(s, r"[\s]+")
    vi = Vector{Int}(undef, length(vs))
    for (i, c) in enumerate(vs)
        vi[i] = parse(Int, c)
    end
    return vi
end

function solve1(io::IO)
    strtime = readline(io)
    strdist = readline(io)
    strtime = split(strtime, ':')[2]
    strdist = split(strdist, ':')[2]

    tvec = numstring2vec(strtime)
    dvec = numstring2vec(strdist)

    winprod = 1
    for i in 1:length(tvec)
        winprod *= testallraces(tvec[i], dvec[i])
    end
    return winprod
end



#= 
    Part 2
=#
function parseline(s::String)::Int
    s = split(s, ':')[2]
    s = replace(s, " " => "")
    return parse(Int, s)
end

function solve2(io::IO)
    strtime = readline(io)
    strdist = readline(io)
    t = parseline(strtime)
    d = parseline(strdist)
    return testallraces(t, d)
end

@testset "day06" begin
    @test solve1(IOBuffer(TEST_STRING)) == 288
    @test solve2(IOBuffer(TEST_STRING)) == 71503
end





end # module