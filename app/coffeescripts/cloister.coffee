class Cloister
  constructor: (row, col) ->
    @size = 0
    @finished = false

    @tiles = {}
    @neighbours = {}

    for rowOffset in [-1..1]
      for colOffset in [-1..1]
        if not (rowOffset is 0 and colOffset is 0)
          otherRow = row + rowOffset
          otherCol = col + colOffset
          @neighbours[otherRow + ',' + otherCol] =
            row: otherRow
            col: otherCol

    @add(row, col)

  add: (row, col) ->
    @tiles[row + "," + col] = true

    @size += 1
    if @size is 9
      @finished = true

  toString: ->
    out = "Cloister: ("
    for address of @tiles
      out += "#{address}; "
    out.slice(0, -2) + "), size: #{@size}, finished: #{@finished}"
