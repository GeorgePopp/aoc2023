## Day 01

The first problem was relatively easly to sovle using the `v = [filter(isdigit, collect(s)) for s in eachline(io)]` oneliner. The second part needed regex. Using regex in Julia isn't too disimilar to Python.

## Day 02

I felt it was best to use a `struct` for the bag and the game. Again I relied on regex to extract the key data from the file.

## Day 03

I found this problem harder than the previous two. At first, I tried to make do with an `Array{Char}` but this ended up making life needlessly difficult. For example, it was challenging to identify the start/end of the numbers. I decided to use `struct`s for problem 2. I could go back and redo problem 1 using the same `struct` but I've already spent a long time on this problem today.

I also discovered (and then subsequently overused) `CaresianIndex` which probably wasn't needed but I can see the value they would bring for more complex data structures.

## Day 04

I found this problem easier than yesterday's. I used recursion for the second part of the challenge. I haven't come across many day-to-day uses of recursion so it was fun to think in terms of a recursive function. I also tried benchmarking and profiling the code to make it faster. I used `@time` and `@benchmark` (from `BenchmarkTools`) for benchmarking, `@code_warntype` to check for type inference, and `@profile` and `@profview` (from `ProfileView`) to profile the code. I was able to make a noticable difference to the running time of the second problem.

## Day 05

The main challenge for part 2 was performance. I made the (ultimately) poor decision to make a large convolution of all the mappings using the very cool `\circ` operator in Julia. My implementation ended up being very slow due to type instability. In the end my code produced the right answer but took a few mins to run. If I had the time, I would have redone the mapping parts to avoid this type unstable convolution. I'm not sure what the best option would be for performance, I'll try and come back to this at a future date.

## Day 06

This problem was quite straightforward as we can simply bruteforce all attempts. The Julia code I wrote didn't need any optimisations and ran basically instantly.

I also managed to get the `@profview` macro working by using `Shift+Enter` to evaluate each line in the REPL rather than running the process. I found the guide for interpreting the output very useful - https://www.julia-vscode.org/docs/stable/userguide/profiler/.

## Day 07

I made use of a custom mutable struct that had defaults that we're filled later. If I was to make this more efficient I could have made struct of arrays instead of an array of structs.

## Day 08

I initially wanted to do something with Binary Trees as it seemed like a good fit for this problem. I came across a straightforward implementation in the [AbstractTrees.jl source code](https://github.com/JuliaCollections/AbstractTrees.jl/blob/master/test/examples/binarytree.jl), but I couldn't think of a good way to populate the tree.

I instead oped to just compare strings, knowing that it could be reasonably slow. 

I tried to bruteforce Part 2 but quickly realised that it would be far too slow. Fortunatly, it was straightforward to break the problem down and  to use [`lcm`](https://docs.julialang.org/en/v1/base/math/#Base.lcm) to calculate the lowest number when each node would end in Z.

