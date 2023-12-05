module day05

using InteractiveUtils

TEST_STRING = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"""



function createmap(a::Array{Vector{Int}})::Function

    function maptemplate(x::Int)::Int
        for v in a
            srcrange = v[2]:(v[2] + v[3])
            destrange = v[1]:(v[1] + v[3])
            if x ∈ srcrange
                idx = x - srcrange[1] + 1 # Get the index value 
                return destrange[idx]
            end
        end
        return x
    end

    return maptemplate
end

function numstring2vec(s::AbstractString)
    # Converts a string of numbers separed by spaces to a Vector{Int}
    s = strip(s) # remove spaces at start/end
    s = replace(s, "  " => " ") # remove double spaces from numbers <10
    vs = split(s, ' ')
    vi = Vector{Int}(undef, length(vs))
    for (i,c) in enumerate(vs)
        vi[i] = parse(Int, c)
    end
    return vi
end

function para2array(s::AbstractString)
    numlines = countlines(IOBuffer(s))
    a = Array{Vector{Int}}(undef, numlines, 1)
    for (i, line) in enumerate(eachline(IOBuffer(s)))
        a[i] = numstring2vec(line)
    end
    return a
end

function getseeds(s::AbstractString)
    s = split(s, ':')[2]
    v = numstring2vec(s)
end

function readparagraph(io)
    buf = IOBuffer()
    while !eof(io)
        line = readline(io; keep=true)
        all(isspace, line) && break
        print(buf, line)
    end
    return String(take!(buf))
end


function solve1(io::IO)
    strseed = readline(io)
    seeds = getseeds(strseed)
    seedloc = copy(seeds)

    for s in eachline(io)
        if contains(s, "map:")
            para = readparagraph(io)
            a = para2array(para)
            f = createmap(a)
            seedloc = f.(seedloc) # apply f to each
        end 
    end
    return minimum(seedloc)
end

#=
    Part 2
=#

function getseedsrange(s::AbstractString)
    v = getseeds(s)
    numseeds = length(v)
    if !iseven(numseeds)
        println("ERROR! - must be even")
    end
    vrng = Vector{UnitRange}(undef, 0)
    for i = 1:(numseeds ÷ 2)
        j = 2 * i - 1
        seedstart = v[j]
        seedrange = v[j+1]
        rng = seedstart:(seedstart + seedrange - 1)
        push!(vrng, rng)
    end
    return vrng
end

function createmap2(a::Array{Vector{UnitRange}})::Function

    function maptemplate(x::Int)::Int
        for v in a
            srcrange = v[2]:(v[2] + v[3])
            destrange = v[1]:(v[1] + v[3])
            if x ∈ srcrange
                idx = x - srcrange[1] + 1 # Get the index value 
                return destrange[idx]
            end
        end
        return x
    end

    return maptemplate
end

function createfullmap(io::IO)::Function
    g(x) = x
    for s in eachline(io)
        if contains(s, "map:")
            para = readparagraph(io)
            a = para2array(para)
            f = createmap(a)
            g = f ∘ g # create composition function
        end 
    end
    return g
end

function para2arrayrange(s::String)
    numlines = countlines(IOBuffer(s))
    a = Array{UnitRange}(undef, numlines, 2)
    for (i, line) in enumerate(eachline(IOBuffer(s)))
        v = numstring2vec(line)
        srcrng = v[2]:(v[2] + v[3])
        destrange = v[1]:(v[1] + v[3])
        a[i, 1] = srcrng
        a[i, 2] = destrange
    end
    return a
end

function solve2(io::IO)
    strseed = readline(io)
    seedsrange = getseedsrange(strseed)
    seedmap = createfullmap(io)
    num_ranges = length(seedsrange)
    println("There are ", num_ranges, " ranges to go through")

    curr_min = 999999999999999
    for (i, seeds) in enumerate(seedsrange)
        seedloc = seedmap.(seeds) # apply f to each
        rng_min = minimum(seedloc)
        curr_min = min(curr_min, rng_min)
        println(i)
        println("Current min: ", curr_min)
    end
    return curr_min
end



end # module