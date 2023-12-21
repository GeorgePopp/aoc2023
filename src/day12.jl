module day12

#= 
    Part 1
=#

TEST_STRING = """???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"""

function parseinput(io::IO)
    numlines = countlines(io)
    seekstart(io)
    st = Vector{String}(undef, numlines)
    nm = Vector{Vector{Int}}(undef, numlines)
    for (i,s) in enumerate(eachline(io))
        s = split(s, ' ')
        # Strings
        st[i] = s[1]
        
        # Numbers
        nm[i] = numstring2vec(s[2])   
    end
    return st, nm
end

function numstring2vec(s::AbstractString)
    # Converts a string of numbers separed by commas to a Vector{Int}
    s = strip(s) # remove spaces at start/end
    vs = split(s, ',')
    vi = Vector{Int}(undef, length(vs))
    for (i, c) in enumerate(vs)
        vi[i] = parse(Int, c)
    end
    return vi
end

function isvalidconfig(s::AbstractString, v::Vector{Int})
    s = replace(s, r"[\.]+" => '.')
    vs = split(s, '.')
    filter!(x->x!="", vs)
    if length(vs) != length(v)
        return false
    else
        for i in 1:length(v)
            if v[i] != length(vs[i])
                return false
            end
        end
        return true
    end
end

function getpossibleconfigs(s::AbstractString)
    n = count('?', s)
    m = 2^n
    a = Array{Bool}(undef, m, n)
    for i in 1:m
        v = digits(i-1, base=2, pad=n)
        a[i,:] = v
    end
    return a
end

function countvalidconfigs(s::AbstractString, v::Vector{Int})
    n = 0
    a = getpossibleconfigs(s)
    svec = split(s, '?')
    for r in eachrow(a)
        t = svec[1]
        for i in 1:length(r)
            if r[i]
                newstr = '#'
            else
                newstr = '.'
            end
            t *= newstr * svec[i+1] 
        end
        if isvalidconfig(t, v)
            n += 1   
        end
    end

    return n
end

function solve1(io::IO)
    arr_s, n = parseinput(f)
    valconfigs = 0
    for i in 1:length(arr_s)
        valconfigs += countvalidconfigs(arr_s[i], n[i])
    end
    return valconfigs
end

function countvalidconfigs_v2(s::String, v::Vector{Int})
    n = count('?', s)
    m = 2^n
    svec = split(s, '?')
    for i in 1:m
        v = digits(i-1, base=2, pad=n)
        t = svec[1]
        for i in 1:length(v)
            if v[i] == 1
                newstr = '#'
            else
                newstr = '.'
            end
            t *= newstr * svec[i+1] 
        end
        if isvalidconfig(t, v)
            n += 1   
        end
    end
    return n
end

function solve1_v2(io::IO)
    arr_s, n = parseinput(io)
    valconfigs = 0
    for i in 1:length(arr_s)
        valconfigs += countvalidconfigs_v2(arr_s[i], n[i])
    end
    return valconfigs
end




#= 
Part 2

Idea:
The only thing that matters is the groups
Can it be represented in a binary vector to make it faster
=#

stringdict = Dict([
    ('#', 1),
    ('.', 0),
    ('?', 0)
])

struct Spring
    groups::Vector{Int8} # Contains the valid groups
    changeids::Vector{Int8} # Represents the positions of the '?'
    basevals::Vector{Bool} # The base string with all ? set to 0
end

function string2boolvec(s::String)
    v = Vector{Bool}(undef, length(s))
    for (i, c) in enumerate(s)
        v[i] = stringdict[c]
    end
    return v
end

function getpos(s::String, ch::Char)
    n = count('?', s)
    v = Vector{Int8}(undef, n)
    i = 1
    for (j, c) in enumerate(s)
        if c == ch
            v[i] = j
            i += 1
        end
    end
    return v
end

function createstruct(s::String, groupvec::Vector{Int})
    baseval = string2boolvec(s)
    changeids = getpos(s, '?')
    return Spring(groupvec, changeids, baseval)
end

function isvalidconfig_v2(v::Vector{Bool}, n)
    """
    What if we removed the trailing and ending zeroes
    """
    group_vec = Vector{Int8}(undef, 0)
    group_count = 0
    group_len = 0
    l = (length(v))
    prev = false
    for i in 1:l
        if v[i]
            prev = true
            group_len += 1
        else
            if prev
                push!(group_vec, group_len)
            end
            prev = false
            group_len = 0
        end
    end
    if v[end]
        push!(group_vec, group_len)
    end
    return group_vec == n
end

function countvalidconfigs_v3(sp::Spring)
    n = length(sp.changeids)
    m = 2^n
    t = sp.basevals
    count = 0
    for i in 1:m
        v = digits(i-1, base=2, pad=n)
        t[sp.changeids] = v
        if isvalidconfig_v2(t, sp.groups)
            count += 1   
        end
    end
    return count
end

function solve1_v3(io::IO)
    arr_s, n = parseinput(io)
    valconfigs = 0
    for i in 1:length(arr_s)
        spring = createstruct(arr_s[i], n[i])
        vals = countvalidconfigs_v3(spring)
        println(vals)
        valconfigs += vals
    end
    return valconfigs
end

function parseinput_2(io::IO)
    numlines = countlines(io)
    seekstart(io)
    st = Vector{String}(undef, numlines)
    nm = Vector{Vector{Int}}(undef, numlines)
    for (i,s) in enumerate(eachline(io))
        s = split(s, ' ')
        # Strings
        t = ""
        for j in 1:5
            t *= s[1] * '?'
        end
        st[i] = t
        
        # Numbers
        nm[i] = repeat(numstring2vec(s[2]), 5)
    end
    return st, nm
end

function solve2(io::IO)
    arr_s, n = parseinput_2(io)
    valconfigs = 0
    for i in 1:length(arr_s)
        spring = createstruct(arr_s[i], n[i])
        vals = countvalidconfigs_v3(spring)
        #println(vals)
        valconfigs += vals
    end
    return valconfigs
end


end