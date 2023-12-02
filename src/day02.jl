module day02

using ..InlineTest # Relative import so it imports from the top level module


struct bag
    red::Int
    green::Int
    blue::Int
end

struct game
    id::Int
    red::Int
    green::Int
    blue::Int
end


const TEST_STRING = """Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"""


const firstbag = bag(12, 13, 14)


#= 
    Helper functions
=#
function parseinput(io::IO)
    numgames = countlines(io)
    seekstart(io) # countlines brings us to the end of the file, need to return to top to use eachline()
    
    # Loop through each line and create an array of game structs
    gamearr = Array{game}(undef, numgames)
    i = 1
    for s in eachline(io)
        gamenum = getgame(s)
        sdraws = removegame(s)
        redmax = 0; greenmax = 0; bluemax = 0
        for sd in eachsplit(sdraws, ";")
            # Get colours and check if they are the new biggest
            redmax = max(redmax, getcolour(sd, "red"))
            greenmax = max(greenmax, getcolour(sd, "green"))
            bluemax = max(bluemax, getcolour(sd, "blue"))
        end

        gamearr[i] = game(gamenum, redmax, greenmax, bluemax)
        i += 1

    end
    return gamearr

end

function removegame(s)
    vec = split(s, ":")
    return vec[2] # Game indicator will be the first split
end

function getgame(s)
    regex = r"Game [0-9]+:"
    result = match(regex, s)
    game = match(r"[0-9]+", result.match)
    return parse(Int, game.match)
end

function getcolour(s, colour::String)
    regex = r"[0-9]+" * r" " * Regex(colour)
    result = match(regex, s)
    if result == nothing
        return 0
    else
        num = match(r"[0-9]+", result.match)
        return parse(Int, num.match)
    end
end

function isvalidgame(game::game, bag::bag)
    redvalid = game.red <= bag.red
    greenvalid = game.green <= bag.green
    bluevalid = game.blue <= bag.blue
    return all([redvalid, greenvalid, bluevalid])
end


#=
    Solutions
=#
function solve1(io::IO)
    gamearray = parseinput(io)
    idsum = 0
    for g in gamearray
        valid = isvalidgame(g, firstbag)
        if valid
            idsum = idsum + g.id
        end
    end
    return idsum
end

function solve2(io::IO)
    gamearray = parseinput(io)
    powsum = 0
    for g in gamearray
        powsum += g.red * g.green * g.blue
    end
    return powsum
end


#=
    Tests
=#
@testset "day02" begin
    @test solve1(IOBuffer(TEST_STRING)) == 8
    @test solve2(IOBuffer(TEST_STRING)) == 2286
end

end # module