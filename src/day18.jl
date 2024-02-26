module day18

TEST_STRING = """R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)"""

function solve1(io::IO)
    a = zeros(Bool, 10000, 10000) # Needs to be sufficiently big
    pos = CartesianIndex(5000,5000)
    a[pos] = 1
    for s in eachline(io)
        dir = s[1]
        s = split(s, " ")
        n = parse(Int8, s[2])
        pos = dig!(a, dir, pos, n)
    end
    display(a)
    bfsfloodfill!(a, 5000, 5001) # needs to be a point in the loop
    display(a)
    return sum(a)
end

function dig!(a::Matrix{Bool}, dir::Char, pos::CartesianIndex, n::Integer)
    if dir == 'R'
        # Increase columns / second arg
        for i in 1:n
            pos = CartesianIndex(pos[1], pos[2] + 1)
            a[pos] = 1
        end
    elseif dir == 'L'
        # Decrease cols / second arg
        for i in 1:n
            pos = CartesianIndex(pos[1], pos[2] - 1)
            a[pos] = 1
        end
    elseif dir == 'D'
        # Increase row / first arg
        for i in 1:n
            pos = CartesianIndex(pos[1] + 1, pos[2])
            a[pos] = 1
        end
    elseif dir == 'U'
        # Decrease row / first arg
        for i in 1:n
            pos = CartesianIndex(pos[1] - 1, pos[2])
            a[pos] = 1
        end
    else
        error("Dir not recognised", dir)
    end
    return pos
end


function floodfill!(a::Array{Bool}, x::Int, y::Int)
    if a[x, y] != 1
        a[x, y] = 1
        if x > 1
            floodfill!(a, x - 1, y)
        end
        if x < size(a)[1]
            floodfill!(a, x + 1, y)
        end
        if y > 1
            floodfill!(a, x, y - 1)
        end
        if y < size(a)[2]
            floodfill!(a, x, y + 1)
        end
    end
end

function bfsfloodfill!(a::Array{Bool}, x::Int, y::Int)
    rows, cols = size(a)
    queue = [(x, y)]
    while !isempty(queue)
        (cx, cy) = pop!(queue)
        if cx >= 1 && cx <= rows && cy >= 1 && cy <= cols && a[cx, cy] != 1
            a[cx, cy] = 1
            push!(queue, (cx - 1, cy))
            push!(queue, (cx + 1, cy))
            push!(queue, (cx, cy - 1))
            push!(queue, (cx, cy + 1))
        end
    end
end
  


# Testing
#f = IOBuffer(TEST_STRING)
f = open("data/day18.txt")
println(solve1(f))

end