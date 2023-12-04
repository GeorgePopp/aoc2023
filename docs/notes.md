## Day 01

The first problem was relatively easly to sovle using the `v = [filter(isdigit, collect(s)) for s in eachline(io)]` oneliner. The second part needed regex. Using regex in Julia isn't too disimilar to Python.

## Day 02

I felt it was best to use a `struct` for the bag and the game. Again I relied on regex to extract the key data from the file.

## Day 03

I found this problem harder than the previous two. At first, I tried to make do with an `Array{Char}` but this ended up making life needlessly difficult. For example, it was challenging to identify the start/end of the numbers. I decided to use `struct`s for problem 2. I could go back and redo problem 1 using the same `struct` but I've already spent a long time on this problem today.

I also discovered (and then subsequently overused) `CaresianIndex` which probably wasn't needed but I can see the value they would bring for more complex data structures.

## Day 04

I found this problem easier than yesterday's. I used recursion for the second part of the challenge. I haven't come across many day-to-day uses of recursion so it was fun to think in terms of a recursive function. I also tried benchmarking and profiling the code to make it faster. I used `@time` and `@benchmark` (from `BenchmarkTools`) for benchmarking, `@code_warntype` to check for type inference, and `@profile` and `@profview` (from `ProfileView`) to profile the code. I was able to make a noticable difference to the running time of the second problem.