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

function createadjacencymatrix(a::Array{Bool}, emptycols::Vector{Int}, emptyrows::Vector{Int})
    nrow, ncol = size(a)
    adjm = zeros(Int, length(a), length(a))

    coords = CartesianIndices(a)
    
    for i in 1:length(a) # from
        fromcoods = coords[i]
        for j in 1:length(a) # to
            tocoods = coords[j]
            adjm[i,j] = calcdistance(fromcoods, tocoods, emptycols, emptyrows)            
        end
    end
    return adjm
end

function calcdistance(from::CartesianIndex, to::CartesianIndex, emptycols::Vector{Int}, emptyrows::Vector{Int})
    row_diff = from[1] - to[1]
    col_diff = from[2] - to[2]

    extradist = 2

    if abs(row_diff) == 1 && col_diff == 0
        if to[1] ∈ emptyrows
            return extradist
        else
            return 1
        end
        
    elseif row_diff == 0 && abs(col_diff) == 1
        if to[2] ∈ emptycols
            return extradist
        else
            return 1
        end

    else
        return 0
    end
end


function mindist(dist::Vector{Int64}, processed::Vector{Bool})
    min = typemax(Int64)
    minidx = 0
    for (i, d) in enumerate(dist)
        if d < min && !processed[i]
            min = d
            minidx = i
        end
    end
    return minidx
end

function dijkstra(a::Array{Bool}, adj::Array{Int}, src::Int)
    dist = [typemax(Int64) for i in eachindex(a)]
    prev = [undef for i in eachindex(a)]
    processed = [false for i in eachindex(a)]
    dist[src] = 0

    for i in eachindex(a)
        u = mindist(dist, processed)
        for j in eachindex(a)
            if adj[u, j] > 0 
                alt = dist[u] + adj[u, j]
                if alt < dist[j]
                    dist[j] = alt
                    #prev[j] = x
                end
            end
            
        end
        processed[u] = true
        
    end
    return dist
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

    adj = createadjacencymatrix(a,ec,er)

    targets = gettargets(a)
    tdist = 0
    @threads for i in 1:length(targets)
        src = targets[i]
        distances = dijkstra(a, adj, src)
        for j in (i+1):length(targets)
            dst = targets[j]
            tdist += distances[dst]
            println("Completed from ", src, " to ", dst)
        end     
    end 
    return tdist
end

#f = IOBuffer(TEST_STRING)
f = open("data/day11.txt")
solve1(f)

end # module