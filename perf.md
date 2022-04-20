# Timing

Run `time nim -d:release r after.nim`

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
