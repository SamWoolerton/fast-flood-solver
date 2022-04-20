import std/[strformat,math]
import sequtils
from strutils import join
import sugar

type Colour = int16

type State = object
  s: seq[Colour]
  sideLength: Natural


type Path = seq[Colour]
type PathState = object
  s: State
  p: Path

type Set = set[Colour]

let startState = block:
  # let state = @[4, 3, 4, 6, 3, 3, 5, 5, 3, 3, 4, 5, 4, 4, 6, 5,
  #     6, 5, 6, 5, 5, 6, 5, 2, 5, 3, 1, 6, 4, 3, 5, 5, 5, 6, 1, 3, 6, 3, 3, 3, 5,
  #     5, 2, 3, 3, 2, 5, 2, 3, 3, 2, 3, 5, 6, 4, 3, 3, 5, 4, 6, 6, 2, 5, 2, 6, 3,
  #     2, 6, 6, 3, 6, 5, 5, 3, 3, 4, 5, 5, 2, 1, 6, 6, 3, 6, 3, 3, 5, 6, 3, 2, 6,
  #     4, 3, 2, 4, 4, 6, 3, 5, 4]
  let state = @[4,3,4,6,3,3,5,5,3,3,4,5,4,4,6,5,6,5,6,5,5,6,5,2,5,3,1,6,4,3,5,5,5,6,1,3,6,3,3,3,5,5,2,3,3,2,5,2,3]
  # let state = @[4,3,4,6,3,3,5,5,3]
  
  State(s: state.map((x) => int16(x)), sideLength: state.len.float.sqrt.round.Natural)


proc printState(state: State) =
  state.s.distribute(state.sideLength).mapIt(join(it, " ")).join("\n").echo

proc findCellNeighbours(state: State, index: int16): Set =
  var neighbours: Set = {}
  let l = state.sideLength
  let col = (index mod l).int16

  if index >= l: neighbours.incl({(index - l).int16})
  if index <= (state.s.len - l - 1): neighbours.incl({(index + l).int16})
  if col > 0: neighbours.incl({index - 1})
  if col < (l - 1): neighbours.incl({index + 1})
  
  return neighbours

proc findContiguousArea(state: State): (Set, Set) =
  var area = {0.int16}
  var areaNeighbours: Set = {}
  var checked = {0.int16}
  let s = state.s
  var queue = @[0.int16]

  while queue.len > 0:
    let cellIndex = queue.pop()
    let cellNeighbours = findCellNeighbours(state, cellIndex)
    let unchecked = cellNeighbours - (checked * cellNeighbours)
    checked = checked + unchecked

    for neighbourIndex in unchecked:
      if s[neighbourIndex] == s[cellIndex]:
        area.incl({neighbourIndex})
        queue.add(neighbourIndex)
      else:
        areaNeighbours.incl({neighbourIndex})

  return  (area, areaNeighbours)

proc findValidMoves(state: State, areaNeighbours: Set): Set =
  var options: Set = {}
  for cellIndex in areaNeighbours:
    options.incl({state.s[cellIndex]})
  return options

proc isFinished(areaNeighbours: Set): bool = 
  return areaNeighbours.card == 0

proc step(pathState: PathState, move: Colour, area: Set): PathState =
  var newPath = pathState.p
  newPath.add(move)

  let newStateData: seq[Colour] = collect:
    for (i, cell) in pathState.s.s.pairs:
      if i.int16 in area: move
      else: cell

  return PathState(s: State(s: newStateData, sideLength: pathState.s.sideLength), p: newPath)

proc solve(state: State): Path = 
  var pathStates: seq[PathState] = @[PathState(s: state, p: @[])]
  var stepCount = 0
  var filledCells: seq[int] = @[]

  # each iteration, loop through each path and progress by one move
  while true:
    stepCount += 1
    echo &"### Starting iteration #{stepCount} with {pathStates.len} paths"

    var newPathStates: seq[PathState] = @[]
    for p in pathStates:
      # copy because branching and don't have structural sharing
      let (area, areaNeighbours) = findContiguousArea(p.s)
      filledCells.add(area.card)

      # exit state - return with the first valid path found
      if isFinished(areaNeighbours): return p.p

      let validMoves = findValidMoves(state, areaNeighbours)
      for m in validMoves: newPathStates.add(step(p, m, area))
    
    pathStates = newPathStates

    echo &"Had max {filledCells.max} and min {filledCells.min} cells filled"
    filledCells = @[]

startState.printState
echo startState.solve
