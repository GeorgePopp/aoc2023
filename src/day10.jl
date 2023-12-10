module day10

using ..InlineTest

#= 
    Part 1
=#

TEST_STRING = """-L|F7
7S-7|
L|7||
-L-J|
L|-JF"""

const paths_ver = ['N', 'S']
const paths_hor = ['E', 'W']
const paths_L = ['N', 'E']
const paths_J = ['N', 'W']
const paths_7 = ['S', 'W']
const paths_F = ['S', 'E']

const s_chars = ['|', '-', 'L', 'J', '7', 'F']

paths = Dict([
    ('|', paths_ver),
    ('-', paths_hor),
    ('L', paths_L),
    ('J', paths_J),
    ('7', paths_7),
    ('F', paths_F),
    ('.', [])
])


function parseinput(io::IO)
    numlines = countlines(io)
    seekstart(io)
    numcols = length(readline(io))
    seekstart(io)
    a = Array{Char}(undef, numlines, numcols)
    for (row, s) in enumerate(eachline(io))
        for (col, c) in enumerate(s)
            a[row, col] = c
        end
    end
    return a
end



function getnextpos(cpos::CartesianIndex, a::Array{Char}, move::Char)
    if move == 'N'
        npos = CartesianIndex(cpos[1]-1, cpos[2])
    elseif move == 'S'
        npos = CartesianIndex(cpos[1]+1, cpos[2])
    elseif move == 'W'
        npos = CartesianIndex(cpos[1], cpos[2]-1)
    elseif move == 'E'
        npos = CartesianIndex(cpos[1], cpos[2]+1)
    else
        npos = nothing
    end
    return npos
end

function isvalidmove(npos::CartesianIndex, a::Array{Char}, move::Char, s::Char)
    nrow, ncol = size(a)

    # Check the move doesn't take us out the array
    if npos[1] < 1 || npos[2] < 1 || npos[1] > nrow || npos[2] > ncol
        return false
    end

    # Check that the next cell can accept the move
    nchar = a[npos]
    if nchar == 'S'
        nchar = s
    elseif nchar == '.'
        return false
    end
    possible_entries = paths[nchar]
    entry = flipmove(move)
    if entry ∈ possible_entries
        return true
    else
        return false
    end 
end

function getnextmove(pos::CartesianIndex, a::Array{Char}, lastmove::Char)
    c = a[pos]
    possible_moves = paths[c]
    entry = flipmove(lastmove)
    exit = filter(x->x!=entry, possible_moves)[1]
    return exit
end


function flipmove(c::Char)
    if c == 'E'
        return 'W'
    elseif c == 'W'
        return 'E'
    elseif c == 'N'
        return 'S'
    elseif c == 'S'
        return 'N'
    else
        return nothing       
    end  
end

function getloopsize(a)

    start = findfirst(x->x=='S', a)

    # Loop through each possibilities
    is_complete = false; pos = start
    for s in s_chars
        moves = 0; pos = start
        start_moves = paths[s]
        move = start_moves[1] # can pick either as will end up being a looppipe
        while true
            npos = getnextpos(pos, a, move)
            isval = isvalidmove(npos, a, move, s)
            if isval
                pos = npos
                if a[npos] == 'S'
                    return moves
                else
                    move = getnextmove(pos, a, move)
                    moves += 1
                    continue
                end
            else
                break
            end

        end
    end
end

function solve1(io::IO)
    a = parseinput(io)
    loop_size = getloopsize(a)
    maxdist = ceil(loop_size / 2)
    return maxdist
end


#= 
    Part 2
    Count the number of times we cross the loop
=#

TEST_STRING2 = """...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
..........."""

TEST_STRING3 = """.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ..."""

TEST_STRING4 = """FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L"""

function getlooppath!(a) 
    start = findfirst(x->x=='S', a)

    # Loop through each possibilities
    is_complete = false; pos = start
    for s in s_chars
        pos = start; loop = Vector{CartesianIndex}(undef, 0)
        start_moves = paths[s]
        move = start_moves[1] # can pick either as will end up being a looppipe
        while true
            npos = getnextpos(pos, a, move)
            isval = isvalidmove(npos, a, move, s)
            if isval
                pos = npos
                push!(loop, pos)
                if a[npos] == 'S'
                    a[npos] = s
                    return loop, a
                else
                    move = getnextmove(pos, a, move)
                    continue
                end
            else
                break
            end

        end
    end 
end

function path2array(a, looppath)
    nrow, ncol = size(a)
    arr = Array{Bool}(undef, nrow, ncol)

    for i in 1:nrow
        for j in 1:ncol
            pos = CartesianIndex(i, j)
            arr[i, j] = pos ∈ looppath 
        end 
    end
    return arr
end


function getnboundaryarray(a, looppath)
    nrow, ncol = size(a)
    arr = Array{Bool}(undef, nrow, ncol)

    for i in 1:nrow
        for j in 1:ncol
            pos = CartesianIndex(i, j)
            c = a[pos]
            exits = paths[c]
            arr[i, j] = (pos ∈ looppath) && ('N' ∈ exits)
        end 
    end
    return arr
end

function getwboundaryarray(a, looppath)
    nrow, ncol = size(a)
    arr = Array{Bool}(undef, nrow, ncol)

    for i in 1:nrow
        for j in 1:ncol
            pos = CartesianIndex(i, j)
            c = a[pos]
            exits = paths[c]
            arr[i, j] = (pos ∈ looppath) && ('W' ∈ exits)
        end 
    end
    return arr
end


function getcontained(a, looppath)
    looparr = path2array(a, looppath)
    varr = getnboundaryarray(a, looppath)
    harr = getwboundaryarray(a, looppath)
    nrow, ncol = size(a)
    arr = Array{Bool}(undef, nrow, ncol)
    for i in 1:nrow
        for j in 1:ncol
            arr[i,j] = 0
            if !looparr[i,j]
                # Truncate each 
                row_vec1 = varr[i, :][1:j]
                row_vec2 = varr[i, :][j:end]
                col_vec1 = harr[:, j][1:i]
                col_vec2 = harr[:, j][i:end]
                
                # count number of times we cross the loop
                row_left_sum = sum(row_vec1)
                row_right_sum = sum(row_vec2)
                col_top_sum = sum(col_vec1)
                col_bottom_sum = sum(col_vec2)

                # all odd => contained in loop
                if isodd(row_left_sum) && isodd(row_right_sum) && isodd(col_top_sum) && isodd(col_bottom_sum)
                    arr[i,j] = 1
                end
                
            end
        end
    end
    return arr
end

function solve2(io::IO)
    c_array = parseinput(io)
    looppath, c_array = getlooppath!(c_array)
    inlooparray = getcontained(c_array, looppath)
    return sum(inlooparray)
end

#= 
    Tests
=#
@testset "day10" begin
    @test solve1(IOBuffer(TEST_STRING)) == 4
    @test solve2(IOBuffer(TEST_STRING2)) == 4
    @test solve2(IOBuffer(TEST_STRING3)) == 8
    @test solve2(IOBuffer(TEST_STRING4)) == 10
end


end