import std/[json, math, strformat, tables, times]
import sequtils
from strutils import join
import sugar
import algorithm

type Colour = range[0..10]
type CellIndex = range[0..99]

type State = object
  s: seq[Colour]
  sideLength: Natural

type Set = set[CellIndex]

type
  Path = ref object
    colour: Colour
    previous: Path
  PathState = object
    area: Set
    areaNeighbours: Set
    path: Path

type JsonState = object
  grid: seq[seq[Colour]]


proc printState(state: State) =
  state.s.distribute(state.sideLength).mapIt(join(it, " ")).join("\n").echo

proc printSet(s: Set, len: int16) = 
  var str = ""
  for i in 0..<(len * len):
    if i.int16 in s: str &= "#"
    else: str &= "_"

    if i > 0 and (i mod len == 0): str &= "\n"
  echo str

proc findCellNeighbours(state: State, index: CellIndex): Set =
  var neighbours: Set = {}
  let l = state.sideLength
  let col = (index mod l).int16

  if index >= l: neighbours.incl((index - l).int16)
  if index <= (state.s.len - l - 1): neighbours.incl((index + l).int16)
  if col > 0: neighbours.incl(index - 1)
  if col < (l - 1): neighbours.incl(index + 1)

  return neighbours

proc findAreaNeighbours(state: State, area: Set, newAreaCells: Set, startingAreaNeighbours: Set): Set =
  # for new area cells, calculate neighbours that aren't in area already
  var newNeighbours: Set = {}
  for n in newAreaCells:
    newNeighbours = newNeighbours + findCellNeighbours(state, n)
  newNeighbours = newNeighbours - area

  # flood find new neighbours
  var checked: Set = {}
  var queue: seq[CellIndex] = @[]
  for n in newNeighbours: queue.add(n)

  while queue.len > 0:
    let cellIndex = queue.pop()
    let cellNeighbours = findCellNeighbours(state, cellIndex)
    let neighboursNotInArea = (cellNeighbours - area) - checked

    # this needs to compare back to the neighbour cell
    for neighbourIndex in neighboursNotInArea:
      if state.s[neighbourIndex] == state.s[cellIndex]:
        newNeighbours.incl(neighbourIndex)
        queue.add(neighbourIndex)
        checked.incl(neighbourIndex)

  return startingAreaNeighbours + newNeighbours

proc findValidMoves(state: State, areaNeighbours: Set): Set =
  var options: Set = {}
  for cellIndex in areaNeighbours:
    options.incl(state.s[cellIndex])
  return options

proc isFinished(areaNeighbours: Set): bool =
  return areaNeighbours.card == 0

proc step(state: State, p: PathState, move: Colour): PathState =
  let newPath = Path(colour: move, previous: p.path)
  # intentionally clone so not sharing with another path
  var area = p.area
  var areaNeighbours = p.areaNeighbours

  # add matching neighbours to area set and remove from neighbours set
  var potentiallyHasNewNeighbours: Set = {}
  for cellIndex in areaNeighbours:
    let colour = state.s[cellIndex]
    if colour == move:
      area.incl(cellIndex)
      areaNeighbours.excl(cellIndex)
      potentiallyHasNewNeighbours.incl(cellIndex)

  areaNeighbours = findAreaNeighbours(state, area, potentiallyHasNewNeighbours, areaNeighbours)

  return PathState(area: area, areaNeighbours: areaNeighbours, path: newPath)

proc getStartingPathState(state: State): PathState =
  let areaNeighbours: Set = findAreaNeighbours(state, {}, {0.CellIndex}, {0.CellIndex})
  return step(state, PathState(area: {}, areaNeighbours: areaNeighbours, path: Path()), state.s[0])

proc prune(pathStates: var seq[PathState], sideLength: int16): seq[PathState] = 
  let l = pathStates.len

  # special-case as there's nothing to prune or sort
  if l == 1: return pathStates

  # intentionally sort in reverse so that `solve` will hit early termination
  pathStates.sort((a, b) => cmp(b.area.card, a.area.card))

  let maxPruneCount = (l * 2 / 3).trunc.int
  let remaining = l - maxPruneCount
  let topCount = min(15, remaining)
  let top = pathStates[0..<topCount]
  
  var prunedCount = 0
  # necessary to skip outer loop
  var prunePath = false

  let pruned = collect:
    for index in countdown(l - 1, 0):
      prunePath = false
      template ps: PathState = pathStates[index]

      if index >= topCount and prunedCount <= maxPruneCount:
        for t in top:
          if ps.area <= t.area:
            inc prunedCount
            prunePath = true
            break
        if prunePath: continue

      ps

  echo &"Pruned {prunedCount}/{l} paths"
  return pruned


proc solve(state: State): Path =
  var pathStates: seq[PathState] = @[getStartingPathState(state)]
  var stepCount = 0
  var filledCells: seq[int] = @[]

  # each iteration, loop through each path and progress by one move
  while true:
    stepCount += 1
    echo &"- Starting iteration #{stepCount} with {pathStates.len} paths"

    var newPathStates: seq[PathState] = @[]
    for p in pathStates:
      let validMoves = findValidMoves(state, p.areaNeighbours)
      for m in validMoves:
        let ps = step(state, p, m)
        newPathStates.add(ps)

        # tracking summary stats
        filledCells.add(ps.area.card)

        # exit state - return with the first valid path found
        if isFinished(ps.areaNeighbours): return ps.path

    echo &"Max {filledCells.max} and min {filledCells.min} cells filled"
    pathStates = newPathStates.prune(state.sideLength.int16)
    filledCells = @[]

proc `$`(path: Path): string =
  var current = path
  # don't print the selection of the starting cell, otherwise it would be a single .previous
  while current.previous.previous != nil:
    result = fmt"{current.colour} " & result
    current = current.previous

proc parseStates(): seq[State] = 
  let providedStates = readFile("states.json").parseJson.to(seq[JsonState])
  var parsedStates: seq[State] = @[]
  for s in providedStates:
    let state = collect:
      for row in s.grid:
        for cell in row:
          Colour(cell)
    parsedStates.add State(s: state, sideLength: 10)
  return parsedStates

proc main() =
  let parsedStates = parseStates()
  var counter = 0
  for s in parsedStates:
    inc counter

    echo "Starting state solve #", counter
    let time = cpuTime()
  
    s.printState
    echo s.solve

    let seconds = cpuTime() - time
    echo &"Time taken: {seconds:.2f}s\n"

main()
