module day14

TEST_STRING = """O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#...."""

chardict = Dict([
    ('.', 0),
    ('O', 1),
    ('#', 2)
])

function parseinput(io::IO)
    numlines = countlines(io)
    seekstart(io)
    numcols = length(readline(io))
    seekstart(io)
    
    a = Array{Int8}(undef, numlines, numcols)
    for (i, s) in enumerate(eachline(io))
        for (j, c) in enumerate(s)
            a[i, j] = chardict[c]
        end      
    end
    return a
end

function rollnorth!(a::Matrix{Int8})
    numrows, numcols = size(a)
    # Work from the bottom to the top
    # Need to repeat for the total number of rows
    for j in 1:numcols
        for rounds in 2:numrows
            for i in reverse(2:rounds)
                x = a[i, j]
                above = a[i-1, j]
                if above == 0 && x == 1
                    a[i-1,j] = x
                    a[i,j] = 0
                end
            end
        end
    end
    return a
end

function calculateload(a::Matrix{Int8})
    b = map(x->x==1, a)
    numrows, numcols = size(a)
    load = 0
    for (i,r) in enumerate(eachrow(b))
        load += (numrows + 1 - i) * sum(r)
    end
    return load
end

function solve1(io::IO)
    a = parseinput(io)
    rollnorth!(a)
    load = calculateload(a)
    return load
end

#f = open("data/day14.txt")
#println(solve1(f))


#= 
Part 2
=#
function rollsouth(a::Matrix{Int8})
    # Reorder rows then rollnorth!, the reorder rows
    a_new = rot180(a)
    rollnorth!(a_new)
    a = rot180(a_new)
    return a
end

function rollwest(a::Matrix{Int8})
    # Reorder rows then rollnorth!, the reorder rows
    a_new = rotr90(a)
    rollnorth!(a_new)
    a = rotl90(a_new)
    return a
end

function rolleast(a::Matrix{Int8})
    # Reorder rows then rollnorth!, the reorder rows
    a_new = rotl90(a)
    rollnorth!(a_new)
    a = rotr90(a_new)
    return a
end

function cycleroll(a::Matrix{Int8})
    #NWSE
    rollnorth!(a)
    a = rollwest(a)
    a = rollsouth(a)
    a = rolleast(a)
    return a
end

function findperiod(a)
    arr = Vector{Int}(undef, 1000)
    j = 0
    for i in 1:1000
        a_old = copy(a)
        a = cycleroll(a)
        arr[i] = calculateload(a)
        
    end
    return arr
end

function solve2(io::IO)
    a = parseinput(io)
    for i in 1:10000
        a_old = copy(a)
        a = cycleroll(a)
        println(i, " ", calculateload(a))
        if a_old == a
            # Converged
            break
        end
    end
    load = calculateload(a)
    return load
end





end