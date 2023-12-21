module day13

TEST_STRING = """#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#"""

function string2bool(s::String)
    v = Vector{Bool}(undef, length(s))
    for (i, c) in enumerate(s)
        if c == '.'
            v[i] = 0
        elseif c == '#'
            v[i] = 1
        else
            error("Char not recognised")
  
        end
        
    end
    return v
    
end

function parseinput(io::IO)
    v = Vector{Matrix{Bool}}(undef, 0)
    m = Vector{Vector{Bool}}(undef, 0)
    for (i, s) in enumerate(eachline(io))
        if s == ""
            m = transpose(stack(m))
            push!(v, m)
            m = Vector{Vector{Bool}}(undef, 0)
        else
            l = string2bool(s)
            push!(m, l)
        end
    end
    # Add last
    m = transpose(stack(m))
    push!(v, m)
    return v
end

function findhsim(m::Matrix{Bool})
    nrow, ncol = size(m)
    v = Vector{Int8}(undef,0)
    for i in 2:ncol
        c1 = m[:, i-1]
        c2 = m[:, i]
        if c1 == c2
            push!(v, i)
        end
    end

    # Check to see if this is a valid reflection
    refv = Vector{Bool}(undef, length(v))
    for (j, k) in enumerate(v)
        r = min(ncol - k, k-2)
        refv[j] = true
        for i in 1:r
            c1 = m[:, k+i]
            c2 = m[:, k-i-1]
            if c1 != c2
                # not a reflection
                refv[j] = false
                break
            end
        end
        
    end

    # Get valid rows

    return v[refv] .- 1
end

function findvsim(m::Matrix{Bool})
    nrow, ncol = size(m)
    v = Vector{Int8}(undef,0)
    for i in 2:nrow
        r1 = m[i-1, :]
        r2 = m[i, :]
        if r1 == r2
            push!(v, i)
        end
    end

    # Check to see if this is a valid reflection
    refv = Vector{Bool}(undef, length(v))
    for (j, k) in enumerate(v)
        r = min(nrow - k, k-2)
        refv[j] = true
        for i in 1:r
            r1 = m[k+i, :]
            r2 = m[k-1-i, :]
            if r1 != r2
                # not a reflection
                refv[j] = false
                break
            end
        end
        
    end

    return v[refv] .- 1
end


function solve1(io::IO)
    vm = parseinput(io)
    count = 0
    for m in vm
        vcol = findvsim(m)
        vrow = findhsim(m)
        count += sum(vcol) + 100 * sum(vrow)
    end
    return count
end


#= 
    Part 2
=#

function isoneout(v1::Vector{Bool}, v2::Vector{Bool})
    u = v1 .!= v2
    if sum(u) == 1
        return true
    else
        return false
    end
end
function findhsim2(m::Matrix{Bool})
    nrow, ncol = size(m)
    v_match = Vector{Int8}(undef,0)
    v_oneout = Vector{Int8}(undef,0)
    for i in 2:ncol
        c1 = m[:, i-1]
        c2 = m[:, i]
        if c1 == c2
            push!(v_match, i)
        elseif isoneout(c1,c2)
            push!(v_oneout, i)
        end
    end
    return v_match, v_oneout
end

function findvsim2(m::Matrix{Bool})
    nrow, ncol = size(m)
    v_match = Vector{Int8}(undef,0)
    v_oneout = Vector{Int8}(undef,0)
    for i in 2:nrow
        r1 = m[i-1, :]
        r2 = m[i, :]
        if r1 == r2
            push!(v_match, i)
        elseif isoneout(r1, r2)
            push!(v_oneout, i)
        end
    end
    return v_match, v_oneout
end


function findpossiblesmudgesrow(m::Matrix{Bool})
    nrow, ncol = size(m)
    # Search all rows to find where each differs
    vr = Vector{CartesianIndex}(undef, 0)
    for i in 1:nrow
        for j in (i+1):nrow
            r1 = m[i, :]
            r2 = m[j, :]
            if isoneout(r1, r2)
                x = findfirst(r1 .!= r2)
                ci = CartesianIndex(i, x)
                push!(vr, ci)
            end
        end
    end
    return Set(vr)    
end

function findpossiblesmudgescol(m::Matrix{Bool})
    nrow, ncol = size(m)
    # Search all rows to find where each differs
    vc = Vector{CartesianIndex}(undef,0)
    for i in 1:ncol
        for j in (i+1):ncol
            c1 = m[:, i]
            c2 = m[:, j]
            if isoneout(c1, c2)
                x = findfirst(c1 .!= c2)
                ci = CartesianIndex(x, i)
                push!(vc, ci)
            end
        end
    end
    return Set(vc)    
end

function testrows(m::AbstractMatrix{Bool})
    nrow, ncol = size(m)
    n = nrow ÷ 2
    # From the top
    for i in 1:n
        j = 2*i
        mtest = m[1:j, :]
        mid_row = i

        # Divide matrix
        m1 = mtest[1:i, :]
        m2 = mtest[(i+1):j, :]

        # Check if one out
        if size(m2)[1] > 1
            reverse!(m2, dims=1)
        end
        u = m1 .!= m2
        if sum(u) == 1
            vpos = findfirst(u)
            return CartesianIndex(vpos[1], vpos[2])
        end
    end

    # From the bottom
    for i in 1:n
        j = 2*i
        mtest = m[(end-j+1):end, :]
        mid_row = nrow - j + 1

        # Divide matrix
        m1 = mtest[1:i, :]
        m2 = mtest[(i+1):j, :]

        # Check if one out
        if size(m2)[1] > 1
            reverse!(m2, dims=1)
        end
        u = m1 .!= m2
        if sum(u) == 1
            vpos = findfirst(u)
            return CartesianIndex(mid_row + vpos[1] - 1, vpos[2])
        end
        
    end

    return CartesianIndex(0,0)
end

function testcols(m::Matrix{Bool})
    nrow, ncol = size(m)
    n = ncol ÷ 2
    # From the top
    for i in 1:n
        j = 2*i
        mtest = m[:, 1:j]
        mid_col = i

        # Divide matrix
        m1 = mtest[:, 1:i]
        m2 = mtest[:, (i+1):j]

        # Check if one out
        if size(m2)[2] > 1
            reverse!(m2, dims=1)
        end
        u = m1 .!= m2
        if sum(u) == 1
            vpos = findfirst(u)
            return CartesianIndex(vpos[1], mid_col)
        end
    end

    # From the bottom
    for i in 1:n
        j = 2*i
        mtest = m[:, (end-j+1):end]
        mid_col = ncol - j + 1

        # Divide matrix
        m1 = mtest[:, 1:i]
        m2 = mtest[:, (i+1):j]

        # Check if one out
        if size(m2)[2] > 1
            reverse!(m2, dims=2)
        end
        u = m1 .!= m2
        if sum(u) == 1
            vpos = findfirst(u)
            return CartesianIndex(vpos[1], mid_col)
        end
        
    end

    return CartesianIndex(0,0)
end

function solve2(io::IO)
    vm = parseinput(io)
    count = 0
    for m in vm
        # Find old value
        vrow_old = findvsim(m)
        vcol_old = findhsim(m)

        idxc = CartesianIndex(0,0); idxr = CartesianIndex(0,0);
        #idxc = testcols(m)
        idxr = testrows(m)
        idxc = testrows(transpose(m))
        idxc = CartesianIndex(idxc[2], idxc[1])

        if idxc != CartesianIndex(0,0)
            idx = idxc
        elseif idxr != CartesianIndex(0,0)
            idx = idxr
        else
            idx = CartesianIndex(0,0)
        end

        m[idx] = !m[idx]

        vrow_new = findvsim(m)
        vcol_new = findhsim(m)

        if isempty(vrow_old)
            vrow = vrow_new
        else
            vrow = vrow_new[vrow_new .∉ vrow_old]
        end
        if isempty(vcol_old)
            vcol = vcol_new
        else
            vcol = vcol_new[vcol_new .∉ vcol_old]
        end
               
        count += sum(vcol) + 100 * sum(vrow)
        vcol = [0]; vrow=[0];

    end
    return count
    
end


end