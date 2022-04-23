# Timing

Run `time nim -d:release r main.nim`

## 7x7 with 49 cells, before any performance optimisations:

4m05s

### Paths

- Starting iteration #1 with 1 paths
  Had max 1 and min 1 cells filled
- Starting iteration #2 with 2 paths
  Had max 4 and min 2 cells filled
- Starting iteration #3 with 5 paths
  Had max 7 and min 4 cells filled
- Starting iteration #4 with 15 paths
  Had max 15 and min 5 cells filled
- Starting iteration #5 with 50 paths
  Had max 24 and min 7 cells filled
- Starting iteration #6 with 180 paths
  Had max 31 and min 8 cells filled
- Starting iteration #7 with 667 paths
  Had max 37 and min 9 cells filled
- Starting iteration #8 with 2584 paths
  Had max 41 and min 12 cells filled
- Starting iteration #9 with 10347 paths
  Had max 45 and min 13 cells filled
- Starting iteration #10 with 40717 paths
  Had max 47 and min 14 cells filled
- Starting iteration #11 with 151568 paths

  @[3, 4, 5, 3, 4, 5, 1, 2, 3, 6]

## Structural sharing for `path`

4m00s

## Refactor path state to use much less copying

2m39s

## Reorder `solve`

Reordered `solve` so progress logs made more sense (max and min calculations are calculated end of the iteration rather than for previous iteration).
Unexpected performance benefit was that the termination check happened at the start of the loop rather than after each `step` - moving this cut down the runtime dramatically.

42.25s

### Paths

- Starting iteration #1 with 1 paths
  Max 4 and min 2 cells filled
- Starting iteration #2 with 2 paths
  Max 7 and min 4 cells filled
- Starting iteration #3 with 5 paths
  Max 15 and min 5 cells filled
- Starting iteration #4 with 15 paths
  Max 24 and min 7 cells filled
- Starting iteration #5 with 50 paths
  Max 31 and min 8 cells filled
- Starting iteration #6 with 180 paths
  Max 37 and min 9 cells filled
- Starting iteration #7 with 667 paths
  Max 41 and min 12 cells filled
- Starting iteration #8 with 2584 paths
  Max 45 and min 13 cells filled
- Starting iteration #9 with 10347 paths
  Max 47 and min 14 cells filled
- Starting iteration #10 with 40717 paths
  3 4 5 3 4 5 1 2 3 6

## Pruning paths that are dominated by another

6.79s

### Paths

- Starting iteration #1 with 1 paths
  Max 4 and min 2 cells filled
  Pruned 0/2 paths
- Starting iteration #2 with 2 paths
  Max 7 and min 4 cells filled
  Pruned 1/5 paths
- Starting iteration #3 with 4 paths
  Max 15 and min 5 cells filled
  Pruned 2/12 paths
- Starting iteration #4 with 10 paths
  Max 24 and min 7 cells filled
  Pruned 8/34 paths
- Starting iteration #5 with 26 paths
  Max 31 and min 8 cells filled
  Pruned 25/94 paths
- Starting iteration #6 with 69 paths
  Max 37 and min 9 cells filled
  Pruned 96/255 paths
- Starting iteration #7 with 159 paths
  Max 41 and min 14 cells filled
  Pruned 58/587 paths
- Starting iteration #8 with 529 paths
  Max 45 and min 15 cells filled
  Pruned 819/1963 paths
- Starting iteration #9 with 1144 paths
  Max 47 and min 16 cells filled
  Pruned 2227/3966 paths
- Starting iteration #10 with 1739 paths

## Restrict `Set` size

0.21s for 7x7 (second run; first run includes compilation time so is about a second)
8.95s for 10x10

Huge performance gains from restricting `Set` range from `int16` to `0..99` - great work [Yardanico](https://github.com/Yardanico)

Note (per Yardanico again) that using `-d:danger --gc:arc` (disabling runtime checks and switching GC algorithm) improves 10x10 performance further to 7.75s

### Paths for 10x10

- Starting iteration #1 with 1 paths
  Max 10 and min 3 cells filled
  Pruned 0/2 paths
- Starting iteration #2 with 2 paths
  Max 13 and min 6 cells filled
  Pruned 0/6 paths
- Starting iteration #3 with 6 paths
  Max 20 and min 7 cells filled
  Pruned 7/22 paths
- Starting iteration #4 with 15 paths
  Max 30 and min 9 cells filled
  Pruned 11/56 paths
- Starting iteration #5 with 45 paths
  Max 42 and min 10 cells filled
  Pruned 45/189 paths
- Starting iteration #6 with 144 paths
  Max 53 and min 16 cells filled
  Pruned 120/615 paths
- Starting iteration #7 with 495 paths
  Max 65 and min 17 cells filled
  Pruned 111/2091 paths
- Starting iteration #8 with 1980 paths
  Max 75 and min 18 cells filled
  Pruned 120/8383 paths
- Starting iteration #9 with 8263 paths
  Max 84 and min 20 cells filled
  Pruned 5861/35193 paths
- Starting iteration #10 with 29332 paths
  Max 92 and min 22 cells filled
  Pruned 2568/122570 paths
- Starting iteration #11 with 120002 paths
  Max 96 and min 24 cells filled
  Pruned 200639/494494 paths
- Starting iteration #12 with 293855 paths
  Max 99 and min 25 cells filled
  Pruned 801508/1202261 paths
- Starting iteration #13 with 400753 paths

5 2 5 3 6 3 5 6 3 1 2 5 4
