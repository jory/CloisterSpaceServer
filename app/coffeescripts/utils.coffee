Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1

oppositeDirection =
  "north": "south"
  "east" : "west"
  "south": "north"
  "west" : "east"

adjacents =
  north:
    row:-1
    col: 0
  east:
    row: 0
    col: 1
  south:
    row: 1
    col: 0
  west:
    row: 0
    col:-1

offset = (edge, row, col) ->
  offsets = adjacents[edge]
  [row + offsets.row, col + offsets.col]

empty = (obj) ->
  return not obj?
