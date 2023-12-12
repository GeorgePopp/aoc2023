module day11

using Base.Threads
    
TEST_STRING = """...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#....."""

function parseinput(io::IO)
    numlines = countlines(io)
    seekstart(io)
    numcols = length(readline(io))
    seekstart(io)
    a = Array{Bool}(undef, numlines, numcols)
    for (row, s) in enumerate(eachline(io))
        for (col, c) in enumerate(s)
            if c == '#'
                a[row, col] = 1
            else
                a[row, col] = 0
            end
        end
    end
    return a
end


function getemptycols(a::Array{Bool})
    emptycols = Vector{Int}(undef, 0)
    for (i, c) in enumerate(eachcol(a))
        isblank = sum(c) == 0
        if isblank
            push!(emptycols, i)
        end
    end
    return emptycols   
end

function getemptyrows(a::Array{Bool})
    emptyrows = Vector{Int}(undef, 0)
    for (i, r) in enumerate(eachrow(a))
        isblank = sum(r) == 0
        if isblank
            push!(emptyrows, i)
        end
    end
    return emptyrows   
end

function calcdistance(src::CartesianIndex, dst::CartesianIndex, ec, er, edist)
    # Distance will always be difference between rows and columns
    d = abs(src[1] - dst[1]) + abs(src[2] - dst[2])
    
    # Add 1 for each empty column or row we pass
    for r in er
        if r > min(src[1], dst[1]) && r < max(src[1], dst[1])
            d+= edist - 1
        end
    end
    for c in ec
        if c > min(src[2], dst[2]) && c < max(src[2], dst[2])
            d+= edist - 1
        end
    end


    return d
end

function gettargets(a::Array{Bool})
    v = zeros(Int, 0)
    for i in eachindex(a)
        if a[i]
            push!(v, i)
        end
    end
    return v
end


function solve1(io::IO)
    a = parseinput(f)
    ec = getemptycols(a)
    er = getemptyrows(a)


    targets = gettargets(a)
    tdist = 0
    coords = CartesianIndices(a)
    for i in 1:length(targets)
        src = targets[i]
        srccoods = coords[src]
        for j in (i+1):length(targets)
            dst = targets[j]
            dstcoods = coords[dst]
            tdist += calcdistance(srccoods, dstcoods, ec, er, 1)
            #println("Completed from ", src, " to ", dst)
        end     
    end 
    return tdist
end

function solve2(io::IO)
    a = parseinput(f)
    ec = getemptycols(a)
    er = getemptyrows(a)


    targets = gettargets(a)
    tdist = 0
    coords = CartesianIndices(a)
    for i in 1:length(targets)
        src = targets[i]
        srccoods = coords[src]
        for j in (i+1):length(targets)
            dst = targets[j]
            dstcoods = coords[dst]
            tdist += calcdistance(srccoods, dstcoods, ec, er, 1_000_000)
            #println("Completed from ", src, " to ", dst)
        end     
    end 
    return tdist
end



end # module