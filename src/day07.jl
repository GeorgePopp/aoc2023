module day07

using ..InlineTest


#= 
    Part 1
=#

TEST_STRING = """32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"""

@kwdef mutable struct Hand
    score::Int = 0
    cvec::Vector = [0,0,0,0,0]
    cards::String
    bet::Int
end

carddict = Dict([
    ('A', 14),
    ('K', 13),
    ('Q', 12),
    ('J', 11),
    ('T', 10),
    ('9', 9),
    ('8', 8),
    ('7', 7),
    ('6', 6),
    ('5', 5),
    ('4', 4),
    ('3', 3),
    ('2', 2)
])



function numkinds(v::Vector{Int})::Vector{Int}
    uv = unique(v)
    ucount = Vector{Int8}(undef, length(uv))
    for (i, c1) in enumerate(uv)
        count = 0 # Always going to have at least 1
        for c2 in v
            if c1 == c2
                count += 1
            end
        end
        ucount[i] = count
    end
    return ucount
end



function getoutcome(uc::Vector{Int})
    sort!(uc, rev=true)
    if length(uc) == 5 # high card
        return 1        
    elseif uc == [2,1,1,1] # parseinput
        return 2
    elseif uc == [2,2,1]
        return 3
    elseif uc == [3,1,1]
        return 4
    elseif uc == [3,2]
        return 5
    elseif uc == [4,1]
        return 6
    elseif uc == [5]
        return 7
    else
        return 0
    end
end

function assignscore!(h::Hand)
    ucounts = numkinds(h.cvec)
    h.score = getoutcome(ucounts)
end

function string2hand(s::String)::Hand
    s = split(s, " ")
    c = s[1]
    b = parse(Int, s[2])
    return Hand(cards = c, bet = b)
end

function hand2vec(h::Hand)::Vector{Int}
    s = h.cards
    v = Vector{Int8}(undef, 5)
    for (i,c) in enumerate(s)
        v[i] = get(carddict, c, 0)
    end
    return v
end

function addhandvec!(h::Hand)
    h.cvec = hand2vec(h)
end

function islessvecelement(v1::Vector{Int}, v2::Vector{Int})::Bool
    for i = 1:length(v1)
        if v1[i] ==  v2[i]
            continue           
        else
            return v1[i] < v2[i]
        end
    end    
end

function islesshand(h1::Hand, h2::Hand)
    if h1.score < h2.score
        return true        
    elseif (h1.score == h2.score) && islessvecelement(h1.cvec, h2.cvec)
        return true
    else
        return false
    end
end

function solve1(io::IO)
    numlines = countlines(io)
    seekstart(io)
    arr = Vector{Hand}(undef, numlines)
    for (i,s) in enumerate(eachline(io))
        h = string2hand(s)
        addhandvec!(h)
        assignscore!(h)
        arr[i] = h
    end
    sortarr = sort(arr, lt=islesshand, rev=false)
    winnings = 0
    for (i, h) in enumerate(sortarr)
        winnings += i * h.bet        
    end
    return winnings
end

#= 
    Part 2
=#

carddict = Dict([
    ('A', 14),
    ('K', 13),
    ('Q', 12),
    ('J', 1),
    ('T', 10),
    ('9', 9),
    ('8', 8),
    ('7', 7),
    ('6', 6),
    ('5', 5),
    ('4', 4),
    ('3', 3),
    ('2', 2)
])

function numkinds2(v::Vector{Int})::Vector{Int}
    numj = count(==(1), v)
    if numj == 5 # 5 Jokers is 5 of a kind
        return [5]
    end
    vnoj = filter(!=(1), v)
    uv = unique(vnoj)
    ucount = Vector{Int8}(undef, length(uv))
    for (i, c1) in enumerate(uv)
        count = 0 # Always going to have at least 1
        for c2 in v
            if c1 == c2
                count += 1
            end
        end
        ucount[i] = count
    end

    # Joker makes best hand, increase max count by 1
    maxval, idx = findmax(ucount)
    ucount[idx] = maxval + numj
    return ucount
end

function assignscore2!(h::Hand)
    ucounts = numkinds2(h.cvec)
    h.score = getoutcome(ucounts)
end

function solve2(io::IO)
    numlines = countlines(io)
    seekstart(io)
    arr = Vector{Hand}(undef, numlines)
    for (i,s) in enumerate(eachline(io))
        h = string2hand(s)
        addhandvec!(h)
        assignscore2!(h)
        arr[i] = h
    end
    sortarr = sort(arr, lt=islesshand, rev=false)
    winnings = 0
    for (i, h) in enumerate(sortarr)
        winnings += i * h.bet        
    end
    return winnings
end

@testset "day07" begin
    @test solve1(IOBuffer(TEST_STRING)) == 6440
    @test solve2(IOBuffer(TEST_STRING)) == 5905
end

end # module