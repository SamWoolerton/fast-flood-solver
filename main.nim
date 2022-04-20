import std/[strformat,math]
import sequtils
from strutils import join
import sugar

type Colour = int16
type CellIndex = int16

type State = object
  s: seq[Colour]
  sideLength: Natural
  
type Set = set[Colour]

type
  Path = ref object
    colour: Colour
    previous: Path
  PathState = object
    area: Set
    areaNeighbours: Set
    path: Path


let startState = block:
  # let state = @[4, 3, 4, 6, 3, 3, 5, 5, 3, 3, 4, 5, 4, 4, 6, 5,
  #     6, 5, 6, 5, 5, 6, 5, 2, 5, 3, 1, 6, 4, 3, 5, 5, 5, 6, 1, 3, 6, 3, 3, 3, 5,
  #     5, 2, 3, 3, 2, 5, 2, 3, 3, 2, 3, 5, 6, 4, 3, 3, 5, 4, 6, 6, 2, 5, 2, 6, 3,
  #     2, 6, 6, 3, 6, 5, 5, 3, 3, 4, 5, 5, 2, 1, 6, 6, 3, 6, 3, 3, 5, 6, 3, 2, 6,
  #     4, 3, 2, 4, 4, 6, 3, 5, 4]
  let state = @[4,3,4,6,3,3,5,5,3,3,4,5,4,4,6,5,6,5,6,5,5,6,5,2,5,3,1,6,4,3,5,5,5,6,1,3,6,3,3,3,5,5,2,3,3,2,5,2,3]
  # let state = @[4,3,4,6,3,3,5,5,3]
  # let state = @[4,3,6,4,3,3,5,5,3]
  # let state = @[4,4,4,4,4,4,5,5,3]
  
  State(s: state.map((x) => int16(x)), sideLength: state.len.float.sqrt.round.Natural)


proc printState(state: State) =
  state.s.distribute(state.sideLength).mapIt(join(it, " ")).join("\n").echo

proc findCellNeighbours(state: State, index: CellIndex): Set =
  var neighbours: Set = {}
  let l = state.sideLength
  let col = (index mod l).int16

  if index >= l: neighbours.incl({(index - l).int16})
  if index <= (state.s.len - l - 1): neighbours.incl({(index + l).int16})
  if col > 0: neighbours.incl({index - 1})
  if col < (l - 1): neighbours.incl({index + 1})
  
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
    options.incl({state.s[cellIndex]})
  return options

proc isFinished(areaNeighbours: Set): bool = 
  return areaNeighbours.card == 0

proc step(state: State, p: PathState, move: Colour): PathState =
  let newPath = Path(colour: move, previous: p.path)
  var area = p.area
  var areaNeighbours = p.areaNeighbours

  # add matching neighbours to area set and remove from neighbours set
  var potentiallyHasNewNeighbours: Set = {}
  for cellIndex in p.areaNeighbours:
    let colour = state.s[cellIndex]
    if colour == move:
      area.incl(cellIndex)
      areaNeighbours.excl(cellIndex)
      potentiallyHasNewNeighbours.incl(cellIndex)

  areaNeighbours = findAreaNeighbours(state, area, potentiallyHasNewNeighbours, areaNeighbours)

  return PathState(area: area, areaNeighbours: areaNeighbours, path: newPath)

proc getStartingPathState(state: State): PathState = 
  let areaNeighbours: Set = findAreaNeighbours(state, {}, {0.int16}, {0.int16})
  return step(state, PathState(area: {}, areaNeighbours: areaNeighbours, path: Path()), state.s[0])

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
    
    pathStates = newPathStates

    echo &"Max {filledCells.max} and min {filledCells.min} cells filled"
    filledCells = @[]


proc `$`(path: Path): string = 
  var current = path
  # don't print the selection of the starting cell, otherwise it would be a single .previous
  while current.previous.previous != nil:
    result = fmt"{current.colour} " & result
    current = current.previous

startState.printState
echo startState.solve
