module day03

using ..InlineTest

TEST_STRING = raw"""467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."""

struct Cell
    pos::CartesianIndex
    value::Char
    isnum::Bool
    num_id::Int
    num_value::Int
end

function parseinput(io::IO)
    # Function to place input into 2d array
    numlines = countlines(io)
    seekstart(io)
    numrows = length(readuntil(io, "\n"))
    seekstart(io)
    arr = Array{Char}(undef, numlines, numrows)
    for (i, s) in enumerate(eachline(io))
        arr[i,:] = collect(s)
    end
    return arr
end

function isdigitordot(c::Char)
    dig = isdigit(c)
    dot = c == '.'
    return dig | dot
end

function containssymbol(s::String)
    v = filter(isdigitordot, collect(s))
    return length(s) != length(v) # if lengths aren't equal then there has been filtering
end


function findadjasent(arr::Array{Char}, startpos::CartesianIndex, endpos::CartesianIndex)
    # Get row position. Assume start pos and end pos have the same row
    aboverow = max(startpos[1] - 1, 1)
    belowrow = min(startpos[1] + 1, size(arr)[1])

    # Get column position
    leftboundary = min(startpos[2], endpos[2])
    rightboundary = max(startpos[2], endpos[2])

    leftcol = max(leftboundary - 1, 1)
    rightcol = min(rightboundary + 1, size(arr)[2])

    # Construct a test string
    s = ""
    for irow =  aboverow:belowrow
        for icol = leftcol:rightcol
            s *= arr[irow, icol]
        end
    end
    return s
end

function  findadjasentidx(arr::Array{Char}, pos::CartesianIndex)
    # Get row position. Assume start pos and end pos have the same row
    aboverow = max(pos[1] - 1, 1)
    belowrow = min(pos[1] + 1, size(arr)[1])

    leftcol = max(pos[2] - 1, 1)
    rightcol = min(pos[2] + 1, size(arr)[2])

    return CartesianIndices((aboverow:belowrow, leftcol:rightcol))
end

function findwholenumberidx!(arr::Array{Char}, startpos::CartesianIndex, endpos::CartesianIndex)
    # Get column position
    leftboundary = min(startpos[2], endpos[2])
    rightboundary = max(startpos[2], endpos[2])

    # Search right
    nextc = arr[endpos]
    rpos = endpos
    while !isdigit(nextc)
        if rpos[2] == size(arr)[2]
            break
        end
        rpos = CartesianIndex(endpos[1], rpos[2] + 1)
        nextc = arr[rpos]
    end
    endpos = CartesianIndex(endpos[1], rpos[2] - 1)

    # Search left
    nextc = arr[startpos]
    lpos = startpos
    while !isdigit(nextc)
        if lpos[1] == size(arr)[1]
            break
        end
        lpos = CartesianIndex(startpos[1], lpos[2] - 1)
        nextc = arr[lpos]
    end
    startpos = CartesianIndex(endpos[1], lpos[2] - 1)

    return startpos, endpos
end

function findnumber(arr::Array{Char}, pos::CartesianIndex)
    # Search right
    testc = arr[pos]
    rpos = pos; testpos = pos;
    while isdigit(testc)
        rpos = testpos
        testpos = CartesianIndex(pos[1], rpos[2] + 1)
        if testpos[2] > size(arr)[2]
            break
        end
        testc = arr[testpos]
    end
    endpos = rpos

    # Search left
    testc = arr[pos]
    lpos = pos; testpos = pos;
    while isdigit(testc)
        lpos = testpos
        testpos = CartesianIndex(pos[1], lpos[2] - 1)
        if testpos[2] < 1
            break
        end
        testc = arr[testpos]
    end
    startpos = lpos
    
    numpos = CartesianIndices((pos[1]:pos[1], startpos[2]:endpos[2]))

    nums = arr[numpos]
    numstring = join(nums)
    num = parse(Int, numstring)

    return num
end

function createcellarray(arr::Array{Char})
    ncol, nrow = size(arr)

    cellarr = Array{Cell}(undef, nrow, ncol)

    num_id_count = 1
    for i = 1:nrow
        for j = 1:ncol
            pos = CartesianIndex(i,j)
            c = arr[pos]
            dig = isdigit(c)
            if dig
                num = findnumber(arr, pos)
                cell = Cell(pos, c, dig, num_id_count, num)
            else
                num_id_count += 1
                cell = Cell(pos, c, dig, 0, 0)
            end
            cellarr[i,j] = cell
        end
    end
    return cellarr
end





function solve1(io::IO)
    arr = parseinput(io)
    ncol, nrow = size(arr)
    partsum = 0; numstring = "";
    startpos = CartesianIndex(); endpos = CartesianIndex(); 
    for i = 1:nrow
        numstring = ""
        for j = 1:ncol
            c = arr[i,j]
            if isdigit(c)
                if isempty(numstring)
                    # First time
                    startpos = CartesianIndex(i, j)
                    endpos = CartesianIndex(i, j)
                else 
                    endpos = CartesianIndex(i, j)
                end
                # Append
                numstring *= c
            end
            
            if !isempty(numstring) && (!isdigit(c) || j == ncol)
                # End of num, perform check
                checkstring = findadjasent(arr, startpos, endpos)
                ismatch = containssymbol(checkstring)
                if ismatch
                    partsum += parse(Int, numstring)
                end
                numstring = ""; startpos = CartesianIndex(); endpos = CartesianIndex(); 

            end

        end
    end

    return partsum
end



function solve2(io::IO)
    arr = parseinput(io)
    cellarr = createcellarray(arr)
    ncol, nrow = size(arr)
    partsum = 0; numstring = "";
    startpos = CartesianIndex(); endpos = CartesianIndex();
    gearsum = 0

    for i = 1:nrow
        for j = 1:ncol
            cpos = CartesianIndex(i,j)
            c = arr[i,j]
            if c == '*' 
                rec = findadjasentidx(arr, cpos)
                unique_num_count = 0; num_id_arr = Vector{Int}(undef,0); num_arr = Vector{Int}(undef,0)
                # Go through each row and find numbers
                for ii = 1:3
                    for jj = 1:3
                        pos = rec[ii,jj]
                        cell = cellarr[pos]
                        if cell.isnum
                            existingnum = cell.num_id ∈ num_id_arr
                            if !existingnum
                                push!(num_id_arr, cell.num_id)
                                push!(num_arr, cell.num_value)
                            end
                        end
                    end
                end
                nummatches = length(num_id_arr)
                if nummatches == 2
                    # Exactly 2 numbers => Gear!
                    gearsum += num_arr[1] * num_arr[2]
                end
            end
        end
    end
    return gearsum
end




@testset "day03" begin
    @test solve1(IOBuffer(TEST_STRING)) == 4361
    @test solve2(IOBuffer(TEST_STRING)) == 467835
end 


end # module