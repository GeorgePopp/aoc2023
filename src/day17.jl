module day17

using SparseArrays
using Base.Threads

TEST_STRING = """2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533"""

TEST_STRING2 = """24134
32154
32552
34465
45466"""

struct Node
    x::Int64
    y::Int64
    lastdir::Char
    moves::Int8
end

const maxmoves = 3

function parseinput(io::IO)
    numlines = countlines(io)
    seekstart(io)
    numcols = length(readline(io))
    seekstart(io)
    a = Array{Int8}(undef, numlines, numcols)

    for (i, s) in enumerate(eachline(io))
        for (j, c) in enumerate(s)
            a[i, j] = parse(Int8, c)
        end      
    end
    return a
end


function createadjacencymatrix(v::Vector{Node}, a::Array{Int8})
    adj = spzeros(Int8, length(v), length(v))
    for i in 1:length(v)
        for j in 1:length(v)
            adj[i,j] = getconnection(v[i], v[j], a)
        end 
        
    end
    return adj
end

function getdir(from::CartesianIndex, to::CartesianIndex)
    row_diff = from[1] - to[1]
    col_diff = from[2] - to[2]
    if row_diff == 1 && col_diff == 0
        return 'N'
    elseif row_diff == -1 && col_diff == 0
        return 'S'
    elseif row_diff == 0 && col_diff == 1
        return 'W'
    elseif row_diff == 0 && col_diff == -1
        return 'E'
    else
        return 'X'
    end
end

function getconnection(f::Node, t::Node, a::Array{Int8})
    # Direction check
    col_diff = f.x - t.x
    row_diff = f.y - t.y
    if abs(col_diff) > 1 || abs(row_diff) > 1
        return 0
    end

    isadjacent = (abs(col_diff) == 1 && abs(row_diff) == 0) || (abs(col_diff) == 0 && abs(row_diff) == 1)

    if !isadjacent
        return 0
    end

    # Direction check
    d = getdir(CartesianIndex(f.x, f.y), CartesianIndex(t.x, t.y))
    if d != t.lastdir
        return 0
    elseif f.lastdir == 'N' && d == 'S'
        return 0
    elseif f.lastdir == 'S' && d == 'N'
        return 0
    elseif f.lastdir == 'E' && d == 'W'
        return 0
    elseif f.lastdir == 'W' && d == 'E'
        return 0
    end

    # Remaining moves check
    if f.lastdir == t.lastdir && f.moves < 1
        return 0
    elseif f.lastdir != t.lastdir && t.moves != 1
        return 0
    elseif f.lastdir == t.lastdir && f.moves + 1 != t.moves
        return 0
    end

    to_node_cost = a[t.x, t.y]
    return to_node_cost
    
end


function creategrapharray(a::Array{Int8})
    v = Vector{Node}(undef, 0)
    coords = CartesianIndices(a)
    j = 0
    for i in 1:length(a)
        fromcoods = coords[i]
        for last_move_from in ['N', 'S', 'E', 'W']
            for moves_remaining_from in 0:maxmoves
                j += 1
                node = Node(fromcoods[2], fromcoods[1],last_move_from, moves_remaining_from)
                push!(v, node)
            end
        end
    end
    return v
end

function matchingids(v::Vector{Node}, i::Int64)
    node = v[i]
    u = zeros(Bool, length(v))
    for (j, n) in enumerate(v)
        if n.x == node.x && n.y == node.y
            u[j] = 1 
        end
    end
    return u
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

function connectedto(v::Vector{Node}, i::Int, adj::SparseArrays.SparseMatrixCSC{Int8})
    n = v[i]
    col = adj[i, :]

    for j in 1:length(col)
        if col[j] > 0
            println(v[j], " is connected to ", n, " with value ", col[j])
        end
    end
end

function nodeposition(n::Node, c::CartesianIndex)
    if n.x == c[2] && n.y == c[1]
        return true
    else
        return false
    end
end

function dijkstra(vgraph::Vector{Node}, adj::SparseArrays.SparseMatrixCSC{Int8}, src, tgt)
    dist = [typemax(Int64) for i in eachindex(vgraph)]
    prev = [undef for i in eachindex(vgraph)]
    processed = [false for i in eachindex(vgraph)]
    dist[src] = 0

    for i in eachindex(vgraph)
        #println()
        #println()
        #println("Currently at :", i)
        u = mindist(dist, processed)
        #println("Closest node to", vgraph[i], " is ", vgraph[u])
        #if nodeposition(vgraph[u], tgt)
        #    return dist[u]
        #end

        if u == 0
            #println("Couldn't find connection")
            #connectedto(vgraph, i, adj)
            continue
        end

        for j in eachindex(vgraph)
            if adj[u, j] > 0 
                # Find what the direction is to get to j from u, add this to move_history
                #println("Found valid move from: ", coords[u], " to ", coords[j])
                alt = dist[u] + adj[u, j]
                if alt < dist[j]
                    #println("   Found new shortest path from: ",vgraph[u], " to ", vgraph[j])
                    #println("   u = ", u)
                    #println("   j = ", j)
                    #println("   Old path length: ", dist[j])
                    #println("   New path length: ", alt)
                    #println()
                    dist[j] = alt
                    #prev[j] = x
                end
            end
            
        end
        # Need to extend this for all values of vgraph that have the same address
        #proc_id = matchingids(vgraph, u)
        #processed[proc_id] .= true
        processed[u] = true
        if all(processed)
            break
        end
        
    end
    return dist
    
end

function filternodes(v::Vector{Node}, c::CartesianIndex)
    n = length(v)
    u = zeros(Int8, n)
    for i in 1:n
        if nodeposition(v[i], c)
            u[i] = 1
        end
    end
    return u
    
end


function solve1(io::IO)
    # Create arrays
    a = parseinput(f)
    println("Parsed input")
    v = creategrapharray(a)
    println("Created Node vector")
    adj = createadjacencymatrix(v, a)
    println("Created adj matrix")
    target = CartesianIndex(141,141)
    #target = CartesianIndex(13,13)
    dist = dijkstra(v, adj, 1, target)

    target_idxs = filternodes(v, target)

    d = dist .* target_idxs

    filter!(x->x!=0, d)

    return minimum(d) - 1
end



#f = IOBuffer(TEST_STRING)
#f = open("data/day17.txt")
#a = parseinput(f)
#v = creategrapharray(a)
#adj = createadjacencymatrix2(v, a)
#dist = dijkstra(v, adj, 1, CartesianIndex(13,13))
#println(solve1(f))

#= 
    Part 2
=#
TEST_STRING3 = """111111111111
999999999991
999999999991
999999999991
999999999991"""

const maxmoves2 = 10
const minmoves2 = 4


function getconnection2(f::Node, t::Node, a::Array{Int8})
    # Direction check
    col_diff = f.x - t.x
    row_diff = f.y - t.y
    if abs(col_diff) > 1 || abs(row_diff) > 1
        return 0
    end

    isadjacent = (abs(col_diff) == 1 && abs(row_diff) == 0) || (abs(col_diff) == 0 && abs(row_diff) == 1)

    if !isadjacent
        return 0
    end

    # Direction check
    d = getdir(CartesianIndex(f.x, f.y), CartesianIndex(t.x, t.y))
    if d != t.lastdir
        return 0
    elseif f.lastdir == 'N' && d == 'S'
        return 0
    elseif f.lastdir == 'S' && d == 'N'
        return 0
    elseif f.lastdir == 'E' && d == 'W'
        return 0
    elseif f.lastdir == 'W' && d == 'E'
        return 0
    end

    # Remaining moves check
    if f.lastdir == t.lastdir && f.moves < 1 # has enough moves to continue in same direction
        return 0
    elseif f.lastdir != t.lastdir && t.moves != 1 # 1st step == 1
        return 0
    elseif f.lastdir == t.lastdir && f.moves + 1 != t.moves # incremental step
        return 0
    elseif f.lastdir != t.lastdir && f.moves < minmoves2
        return 0
    end

    to_node_cost = a[t.x, t.y]
    return to_node_cost
    
end

function creategrapharray2(a::Array{Int8})
    v = Vector{Node}(undef, 0)
    coords = CartesianIndices(a)
    j = 0
    for i in 1:length(a)
        fromcoods = coords[i]
        for last_move_from in ['N', 'S', 'E', 'W']
            for moves_remaining_from in 0:maxmoves2
                j += 1
                node = Node(fromcoods[2], fromcoods[1],last_move_from, moves_remaining_from)
                push!(v, node)
            end
        end
    end
    return v
end

function createadjacencymatrix2(v::Vector{Node}, a::Array{Int8})
    adj = spzeros(Int8, length(v), length(v))
    for i in 1:length(v)
        for j in 1:length(v)
            adj[i,j] = getconnection2(v[i], v[j], a)
        end 
        
    end
    return adj
end

function solve2(io::IO)
    # Create arrays
    a = parseinput(f)
    println("Parsed input")
    v = creategrapharray2(a)
    println("Created Node vector")
    adj = createadjacencymatrix2(v, a)
    println("Created adj matrix")
    nrow, ncol = size(a)
    target = CartesianIndex(nrow,ncol)
    dist = dijkstra(v, adj, 1, target)

    target_idxs = filternodes(v, target)

    d = dist .* target_idxs

    filter!(x->x!=0, d)

    return minimum(d) - 1
end

#f = IOBuffer(TEST_STRING2)
#f = open("data/day17.txt")
#println(solve2(f))


end