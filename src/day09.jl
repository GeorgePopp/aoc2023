module day09

using ..InlineTest

#= 
    Part 1
=#

TEST_STRING = """0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"""

function diffvec(v::Vector{Int})
    u = Vector{Int}(undef, length(v)-1)
    for i in 1:length(u)
        u[i] = v[i+1] - v[i]
    end
    return u
end


function extrapolate_v(v::Vector{Int})
    final_val = v[end]
    while !all(x->x==0, v)
        v = diffvec(v)
        final_val += v[end] 
    end 
    return final_val
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
    sumval = 0
    for s in eachline(io)
        v = numstring2vec(s)
        sumval += extrapolate_v(v)
    end
    return sumval
end

#= 
    Part 2
=#

function extrapolate_v_start(v::Vector{Int})
    start_val = v[1]
    i = 1
    while !all(x->x==0, v)
        v = diffvec(v)
        start_val = start_val + (-1)^i * v[1]
        i+=1
    end

    return start_val
end

function solve2(io::IO)
    sumval = 0
    for s in eachline(io)
        v = numstring2vec(s)
        sumval += extrapolate_v_start(v)
    end
    return sumval
end


#= 
    Tests
=#

@testset "day09" begin
    @test solve1(IOBuffer(TEST_STRING)) == 114
    @test solve2(IOBuffer(TEST_STRING)) == 2
end



end # module