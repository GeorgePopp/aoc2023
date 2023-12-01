module day01

using ..InlineTest # Relative import so it imports from the top level module

# PART 1

const TEST_STRING = """1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"""

function solve(io::IO)
    v = [filter(isdigit, collect(s)) for s in eachline(io)]
    sum = 0
    for num_vec in v
        num = parse(Int, num_vec[1] * num_vec[end])
        sum += num
    end
    return sum
end

# PART 2

const TEST_STRING2 = """two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"""

const textdigits = [
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine"
]

const digitdict = Dict([
    ("one", 1),
    ("two", 2),
    ("three", 3),
    ("four", 4),
    ("five", 5),
    ("six", 6),
    ("seven", 7),
    ("eight", 8),
    ("nine", 9)
])


function matchtextdigit(s::String)
    # Use regex to match strings and digits, | corresponds to the or character in regex
    regex = join(textdigits, "|") * "|" * "[0-9]"
    results = collect(eachmatch(Regex(regex), s, overlap = true))

    # Loop through the results and parse the matching integer, then add it to an array
    arrdigit = Array{Int}(undef, length(results))
    for (i,m) in enumerate(results)
        if length(m.match) == 1
            # Match is already a digit, covert the string to an integer
            num = parse(Int, m.match)
        else
            # Digit is spelled out with letters, map to integer using the dictionary
            num = get(digitdict, m.match, nothing)
        end
        arrdigit[i] = num
    end

    return arrdigit
end



function solve2(io::IO)
    v = [matchtextdigit(s) for s in eachline(io)]
    sum = 0
    for num_vec in v
        num = parse(Int, string(num_vec[1]) * string(num_vec[end]))
        sum += num
    end
    return sum
end

# Tests
@testset "day01" begin
    @test solve(IOBuffer(TEST_STRING)) == 142
    @test solve2(IOBuffer(TEST_STRING2)) == 281
end


end # module