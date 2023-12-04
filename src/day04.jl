module day04

using ..InlineTest

TEST_STRING = """Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"""

#=
    Part 1
=#


function getcard(s::String)
    # Return the Card number as an integer
    regex = r"Card[\s]+[0-9]+:"
    result = match(regex, s)
    card = match(r"[0-9]+", result.match)
    return parse(Int, card.match)
end

function numstring2vec(s::AbstractString)
    # Converts a string of numbers separed by spaces to a Vector{Int}
    s = strip(s) # remove spaces at start/end
    s = replace(s, "  " => " ") # remove double spaces from numbers <10
    vs = split(s, ' ')
    vi = Vector{Int}(undef, length(vs))
    for (i,c) in enumerate(vs)
        vi[i] = parse(Int, c)
    end
    return vi
end

function extractresults(s::String)
    # Return two vectors, first the winning numbers, second the chosen numbers
    snums = split(s, ":")[2]
    vsplit = split(snums, "|")
    win_vec = numstring2vec(vsplit[1])
    choice_vec = numstring2vec(vsplit[2])
    return win_vec, choice_vec
end

function solve1(io::IO)
    sumpoints = 0
    for s in eachline(io)
        card = getcard(s)
        win_vec, choice_vec = extractresults(s)
        iswin = in.(choice_vec, Ref(win_vec))
        wins = sum(iswin)
        if wins > 0
            sumpoints += 2^(wins-1)
        end
    end
    return sumpoints
    
end


#=
    Part 2
=#


function createintegerarray(io::IO)
    numlines = countlines(io)
    seekstart(io)
    arr = Array{Vector{Int}}(undef, numlines, 2)
    for (i, s) in enumerate(eachline(io))
        win_vec, choice_vec = extractresults(s)
        arr[i,1] = win_vec
        arr[i,2] = choice_vec
    end
    return arr
end

function processcard(cardarr::Array{Vector{Int}}, cardnum::Int)
    if cardnum > size(cardarr)[1]
        return 0
    end
    win_vec = cardarr[cardnum,1]
    choice_vec = cardarr[cardnum,2]
    iswin = in.(choice_vec, Ref(win_vec))
    wins = sum(iswin)
    if wins > 0
        for i = 1:wins
            newcardnum = cardnum + i
            wins += processcard(cardarr, newcardnum)            
        end
    end
    return wins # process this card
end

function solve2(io::IO)
    cardarr = createintegerarray(io)
    cardcount = 0
    for i = 1:size(cardarr)[1]
        cardcount += processcard(cardarr, i) + 1
    end
    return cardcount
end


#=
    Tests
=#

@testset "day04" begin
    @test solve1(IOBuffer(TEST_STRING)) == 13
    @test solve2(IOBuffer(TEST_STRING)) == 30
end 

    
end # module