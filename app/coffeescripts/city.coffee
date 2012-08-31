class City
  constructor: () ->
    @size = 0
    @numPennants = 0
    @finished = false

    @openEdges = []

    @tiles = {}
    @nums = {}
    @edges = {}

  add: (row, col, edge, num, citysFields, hasPennant) ->
    address = "#{row},#{col}"

    if empty(@tiles[address])
      @tiles[address] = citysFields
      @size += 1
      if hasPennant
        @numPennants += 1

    @nums[address + ",#{num}"] = true

    @edges[address + ",#{edge}"] =
      row: row
      col: col
      edge: edge
      num: num

    [otherRow, otherCol] = offset(edge, row, col)
    otherAddress = "#{otherRow},#{otherCol},#{oppositeDirection[edge]}"

    if otherAddress in @openEdges
      @openEdges.remove(otherAddress)
    else
      @openEdges.push(address + ",#{edge}")

    if @openEdges.length is 0
      @finished = true
    else
      @finished = false

  has: (row, col, num) ->
    @nums["#{row},#{col},#{num}"]

  merge: (other) ->
    for e, edge of other.edges
      row = edge.row
      col = edge.col
      @add(row, col, edge.edge, edge.num, other.tiles["#{row},#{col}"], false)
    @numPennants += other.numPennants

  toString: ->
    out = "City: ("
    for address of @tiles
      out += "#{address}; "
    out.slice(0, -2) +
        "), size: #{@size}, finished: #{@finished}, numPennants: #{@numPennants}"
