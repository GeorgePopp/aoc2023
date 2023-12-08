module day08

using ..InlineTest

#= 
    Part 1
=#

TEST_STRING1 = """RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)"""

TEST_STRING2 = """LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)"""


struct MapArray
    name::Vector{String}
    left::Vector{String}
    right::Vector{String}
end

function toMapArray(io::IO)
    nv = Vector{String}(undef, 0)
    lv = Vector{String}(undef, 0)
    rv = Vector{String}(undef, 0)
    for s in eachline(io)
        s = replace(s, [',','=', '(', ')'] => "")
        s = split(s, r"[\s]+")
        push!(nv, s[1])
        push!(lv, s[2])
        push!(rv, s[3])
    end
    return MapArray(nv, lv, rv)    
end


function getnameindex(a::MapArray, name)
    return findfirst(x->x==name, a.name)    
end

function solve1(io::IO)
    moves = readline(io)
    totalmoves = length(moves)
    _ = readline(io)
    a = toMapArray(io)

    name = "AAA"
    idx = getnameindex(a, name)
    count = 0;
    while name != "ZZZ"
        charpos = mod(count, totalmoves) + 1
        nextmove = moves[charpos]
        if nextmove == 'L'
            name = a.left[idx]
            idx = getnameindex(a, name)
        elseif nextmove == 'R'
            name = a.right[idx]
            idx = getnameindex(a, name)
        else
            error("unclear instruction")
        end
        count += 1
    end
    return count
end


#= 
    Part 2
=#

TEST_STRING3 = """LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"""

function endsinZ(s::AbstractString)
    c = s[end]
    return c == 'Z'
end
function endsinA(s::AbstractString)
    c = s[end]
    return c == 'A'
end


function getnameindexvec(a::MapArray, namevec::Vector{String})
    idx = Vector{Int}(undef, length(namevec))
    for (i, n) in enumerate(namevec)
        idx[i] = findfirst(x->x==n, a.name)
    end
    return idx
end


function solve2(io::IO)
    moves = readline(io)
    totalmoves = length(moves)
    _ = readline(io)
    a = toMapArray(io)

    name_vec = filter(endsinA, a.name)
    count_vec = Vector{Integer}(undef, length(name_vec))
    for (i, name) in enumerate(name_vec)
        idx = getnameindex(a, name)
        count = 0;
        while !endsinZ(name)
            charpos = mod(count, totalmoves) + 1
            nextmove = moves[charpos]
            if nextmove == 'L'
                name = a.left[idx]
                idx = getnameindex(a, name)
            elseif nextmove == 'R'
                name = a.right[idx]
                idx = getnameindex(a, name)
            else
                error("unclear instruction")
            end
        count += 1
        end
        count_vec[i] = count
        #println("Completed ", name, " in ", count, " steps.")
    end
    out = lcm(count_vec)
    return out
end


@testset "day08" begin
    @test solve1(IOBuffer(TEST_STRING1)) == 2
    @test solve1(IOBuffer(TEST_STRING2)) == 6
    @test solve2(IOBuffer(TEST_STRING3)) == 6
end

end # module