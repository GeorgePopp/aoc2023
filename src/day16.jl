module day16

using ..InlineTest

TEST_STRING = raw""".|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|...."""

function parseinput(io::IO)
    numlines = countlines(io)
    seekstart(io)
    numcols = length(readline(io))
    seekstart(io)
    a = Array{Char}(undef, numlines, numcols)
    for (i, s) in enumerate(eachline(io))
        for (j, c) in enumerate(s)
            a[i, j] = c
        end      
    end
    return a
end


function inarray(inds, nrow::Int, ncol::Int)
    a = BitVector(undef, length(inds))
    for (j, id) in enumerate(inds)
        if id[1] ≥ 1 && id[1] ≤ ncol && id[2] ≥ 1 && id[2] ≤ nrow
            a[j] = true
        else
            a[j] = false
        end
    end
    return a
end

function movevec(cpos::CartesianIndex, m::Vector{Char})
    out = Vector{CartesianIndex}(undef, length(m))

    for (i, c) in enumerate(m)
        if c == 'N'
            out[i] = CartesianIndex(cpos[1], cpos[2] + 1)
        elseif c == 'S'
            out[i] = CartesianIndex(cpos[1], cpos[2] - 1)
        elseif c == 'E'
            out[i] = CartesianIndex(cpos[1] + 1, cpos[2])
        elseif c == 'W'
            out[i] = CartesianIndex(cpos[1] - 1, cpos[2])
        else
            error("not recognised")
        end
    end
    return out
end

function move(cpos::CartesianIndex, m::Char)

    for (i, c) in enumerate(m)
        if c == 'N'
            return CartesianIndex(cpos[1], cpos[2] - 1)
        elseif c == 'S'
            return CartesianIndex(cpos[1], cpos[2] + 1)
        elseif c == 'E'
            return CartesianIndex(cpos[1] + 1, cpos[2])
        elseif c == 'W'
            return CartesianIndex(cpos[1] - 1, cpos[2])
        else
            error("not recognised")
        end
    end
end

function move2(cpos::CartesianIndex, m::Char)

    for (i, c) in enumerate(m)
        if c == 'W'
            return CartesianIndex(cpos[1], cpos[2] - 1)
        elseif c == 'E'
            return CartesianIndex(cpos[1], cpos[2] + 1)
        elseif c == 'S'
            return CartesianIndex(cpos[1] + 1, cpos[2])
        elseif c == 'N'
            return CartesianIndex(cpos[1] - 1, cpos[2])
        else
            error("not recognised")
        end
    end
end

function findnextmove(a::Array{Char}, cpos::CartesianIndex, lastmove::Char)
    c = a[cpos]
    if c == '.'
        return [lastmove]

    elseif c == '\\'
        if lastmove == 'E'
            return ['S']
        elseif lastmove == 'N'
            return ['W']
        elseif lastmove == 'S'
            return ['E']
        elseif lastmove == 'W'
            return ['N']
        end

    elseif c == '/'
        if lastmove == 'E'
            return ['N']
        elseif lastmove == 'N'
            return ['E']
        elseif lastmove == 'S'
            return ['W']
        elseif lastmove == 'W'
            return ['S']
        end

    elseif c == '-'
        if lastmove == 'E'
            return [lastmove]
        elseif lastmove == 'N'
            return ['E', 'W']
        elseif lastmove == 'S'
            return ['E', 'W']
        elseif lastmove == 'W'
            return [lastmove]
        end

    elseif c == '|'
        if lastmove == 'E'
            return ['N', 'S']
        elseif lastmove == 'N'
            return [lastmove]
        elseif lastmove == 'S'
            return [lastmove]
        elseif lastmove == 'W'
            return ['N', 'S']
        end

    else
        error("Char unrecognised")
    end
    
end

function vecvecsize(v::Vector{Vector{Char}})
    s = 0
    for u in v
        s += size(u)[1]
    end
    return s
    
end

function updatevisited!(a::BitMatrix, cposvec)
    for pos in cposvec
        a[pos] = true
    end
end

function solve1(io::IO)
    a = parseinput(io)
    nrow, ncol = size(a)

    visited = falses(nrow, ncol)

    cpos = CartesianIndex(1,1)
    current_pos = [cpos]
    nmove = findnextmove(a, cpos, 'E')
    next_move = [nmove]
    updatevisited!(visited, current_pos)

    energised_vec = Vector{Int64}(undef, 0)

    stuck = false

    while length(current_pos) > 0 && !stuck
        # Get next position
        next_pos_temp = Vector{CartesianIndex}(undef, 0)
        last_move_temp = Vector{Char}(undef, 0)
        for (i, pos) in enumerate(current_pos)
            for mv in next_move[i]
                npos =  move2(pos, mv)
                push!(next_pos_temp, npos)
                push!(last_move_temp, mv)
            end
        end
        current_pos = next_pos_temp

        # Remove indices outside the array
        isinside = inarray(current_pos, nrow, ncol)
        current_pos = current_pos[isinside]
        last_move_temp = last_move_temp[isinside]

        # Set visit array
        updatevisited!(visited, current_pos)

        # Get next moves
        next_move_temp = Vector{Vector{Char}}(undef, 0)
        for (i, pos) in enumerate(current_pos)
            nmove = findnextmove(a, pos, last_move_temp[i])
            push!(next_move_temp, nmove)
        end
        next_move = next_move_temp

        # Update energised count
        push!(energised_vec, sum(visited))

        # Have we got stuck in a loop?
        same = energised_vec .== sum(visited)
        if sum(same) > 100
            stuck = true
        else
            stuck = false
        end
#=         println("Completed round")
        display(visited)
        println("Current sum: ", sum(visited))
=#
    end
    return energised_vec[end]
end


#= 
    Part 2
=#
function testpath(a::Matrix{Char}, startpos::CartesianIndex, firstmove::Char)
    nrow, ncol = size(a)
    visited = falses(nrow, ncol)

    cpos = startpos
    current_pos = [cpos]
    nmove = findnextmove(a, cpos, firstmove)
    next_move = [nmove]
    updatevisited!(visited, current_pos)

    energised_vec = Vector{Int64}(undef, 0)

    stuck = false

    while length(current_pos) > 0 && !stuck
        # Get next position
        next_pos_temp = Vector{CartesianIndex}(undef, 0)
        last_move_temp = Vector{Char}(undef, 0)
        for (i, pos) in enumerate(current_pos)
            for mv in next_move[i]
                npos =  move2(pos, mv)
                push!(next_pos_temp, npos)
                push!(last_move_temp, mv)
            end
        end
        current_pos = next_pos_temp

        # Remove indices outside the array
        isinside = inarray(current_pos, nrow, ncol)
        current_pos = current_pos[isinside]
        last_move_temp = last_move_temp[isinside]

        # Set visit array
        updatevisited!(visited, current_pos)

        # Get next moves
        next_move_temp = Vector{Vector{Char}}(undef, 0)
        for (i, pos) in enumerate(current_pos)
            nmove = findnextmove(a, pos, last_move_temp[i])
            push!(next_move_temp, nmove)
        end
        next_move = next_move_temp

        # Update energised count
        push!(energised_vec, sum(visited))

        # Have we got stuck in a loop?
        same = energised_vec .== sum(visited)
        if sum(same) > 10
            stuck = true
        else
            stuck = false
        end
#=         println("Completed round")
        display(visited)
        println("Current sum: ", sum(visited)) =#
    
    end
    return energised_vec[end]
end

function solve2(io::IO)
    a = parseinput(io)
    nrow, ncol = size(a)

    start_pos_vec = Vector{CartesianIndex}(undef, 0)
    first_move_vec = Vector{Char}(undef, 0)

    # Top
    top_pos = [CartesianIndex(1, i) for i in 1:ncol]
    top_move = repeat(['S'], length(top_pos))
    append!(start_pos_vec, top_pos)
    append!(first_move_vec, top_move)

    # Right
    right_pos = [CartesianIndex(i, ncol) for i in 1:nrow]
    right_move = repeat(['W'], length(right_pos))
    append!(start_pos_vec, right_pos)
    append!(first_move_vec, right_move)

    # Bottom
    bottom_pos = [CartesianIndex(nrow, i) for i in 1:ncol]
    bottom_move = repeat(['N'], length(bottom_pos))
    append!(start_pos_vec, bottom_pos)
    append!(first_move_vec, bottom_move)

    # Left
    left_pos = [CartesianIndex(i, 1) for i in 1:nrow]
    left_move = repeat(['E'], length(left_pos))
    append!(start_pos_vec, left_pos)
    append!(first_move_vec, left_move)


    # Find max
    engvec = Vector{Int64}(undef, length(start_pos_vec))
    Threads.@threads for i in 1:length(start_pos_vec)
        engvec[i] = testpath(a, start_pos_vec[i], first_move_vec[i])
    end
    return maximum(engvec)
end



@testset "day16" begin
    @test solve1(IOBuffer(TEST_STRING)) == 46
    @test solve2(IOBuffer(TEST_STRING)) == 51
end


end