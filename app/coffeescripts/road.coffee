class Road
  constructor: () ->
    @length = 0
    @numEnds = 0
    @finished = false

    @tiles = {}
    @nums = {}
    @edges = {}

  add: (row, col, edge, num, hasEnd) ->
    address = "#{row},#{col}"

    if not @tiles[address]
      @length += 1
      @tiles[address] = true

    if hasEnd
      @numEnds += 1
      if @numEnds is 2
        @finished = true

    @nums[address + ",#{num}"] = true

    @edges[address + ",#{edge}"] =
      row: row
      col: col
      edge: edge
      num: num
      hasEnd: hasEnd

  merge: (other) ->
    for e, edge of other.edges
      @add(edge.row, edge.col, edge.edge, edge.num, edge.hasEnd)

  has: (row, col, num) ->
    @nums["#{row},#{col},#{num}"]

  toString: ->
    out = "Road: ("
    for address of @tiles
      out += "#{address}; "
    out.slice(0, -2) +
        "), length: #{@length}, finished: #{@finished}, numEnds: #{@numEnds}"
