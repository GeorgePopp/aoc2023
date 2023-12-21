module day15

using ..InlineTest
using DelimitedFiles

TEST_STRING = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

function hashstring(s::String)
    cval = 0
    for c in s
        ascii_val = Int(c)
        cval += ascii_val
        cval *= 17
        cval = cval % 256
    end
    return cval
end

function solve1(io::IO)
    a = DelimitedFiles.readdlm(io, ',', String)
    x = 0
    for s in a
        x += hashstring(s)
    end
    return x
end

#= f = open("data/day15.txt")
println(solve1(f)) =#

#= 
    Part 2

Run hashstring on the label (i.e. bit before = or -)

=#

lenses = collect(1:256) .- 1

struct Lens
    label::String
    focal::Int64
end


mutable struct Boxes
    id::Vector{Int64}
    label::Vector{String}
    focal_length::Vector{Int64}
end

function initialiseBoxes()
    box_num = Vector{Int64}(undef, 0)
    label = Vector{String}(undef, 0)
    focal_length = Vector{Int}(undef, 0)
    return Boxes(box_num, label, focal_length)
end

function putlens!(b::Boxes, l::Lens)
    box_num = hashstring(l.label) + 1
    box_exists = box_num ∈ b.id
    

    # If label already in box, replace. Otherwise append
    if box_exists
        labels_in_box = b.label[b.id .== box_num]
        if l.label ∈ labels_in_box
            # Label exists in the box
            label_box_match = b.id .== box_num .&& b.label .== l.label
            idx = findfirst(label_box_match)
            b.focal_length[idx] = l.focal
        else
            # Label doesn't exist in the box
            push!(b.id, box_num)
            push!(b.label, l.label)
            push!(b.focal_length, l.focal)
        end
    else
        # Box doesn't exist
        push!(b.id, box_num)
        push!(b.label, l.label)
        push!(b.focal_length, l.focal)
    end
end

function removelens!(b::Boxes, l::Lens)
    box_num = hashstring(l.label) + 1
    box_exists = box_num ∈ b.id

    # If label already in box, remoave
    if box_exists
        labels_in_box = b.label[b.id .== box_num]
        if l.label ∈ labels_in_box
            # Label exists in the box
            label_box_match = b.id .== box_num .&& b.label .== l.label
            idx = findfirst(label_box_match)
            popat!(b.id, idx)
            popat!(b.label, idx)
            popat!(b.focal_length, idx)
        else
            # Label doesn't exist in the box
        end
    else
        # Box doesn't exist

    end
end

function solve2(io::IO)
    a = DelimitedFiles.readdlm(io, ',', String)
    b = initialiseBoxes()
    
    for s in a
        # Create label
        st = ""
        lensval = 0
        i=1 ; c = s[i]
        while c != '=' && c != '-'
            st *= c
            i += 1
            c = s[i]
        end

        # Create lens
        box_id = hashstring(st)
        if c == '='
            lensval = parse(Int, s[i+1])
        end
        l = Lens(st, lensval)

        # Add / Remove from box
        if c == '='
            putlens!(b, l)
        elseif c == '-'
            removelens!(b, l)
        end
        #println(b)
    end

    # Find slot position
    num_lenses = length(b.id)
    slots = similar(b.id)
    for i in 1:num_lenses
        slots[i] = sum(b.id[1:i] .== b.id[i])
    end

    # Calculate fusing power
    y = 0
    for i in 1:num_lenses
        y += b.id[i] * slots[i] * b.focal_length[i]
    end


    return y
end



@testset "day15" begin
    @test hashstring("HASH") == 52
    @test solve1(IOBuffer(TEST_STRING)) == 1320
    @test solve2(IOBuffer(TEST_STRING)) == 145

end

end