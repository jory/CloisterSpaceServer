class Farm
  constructor: () ->
    @size = 0
    @score = 0

    @tiles = {}
    @nums = {}
    @edges = {}

  add: (row, col, edge, num) ->
    address = "#{row},#{col}"

    if not @tiles[address]
      @tiles[address] = num
      @size += 1

    @nums[address + ",#{num}"] = true

    @edges[address + ",#{edge}"] =
      row: row
      col: col
      edge: edge
      num: num

  has: (row, col, num) ->
    @nums["#{row},#{col},#{num}"]

  merge: (other) ->
    for e, edge of other.edges
      @add(edge.row, edge.col, edge.edge, edge.num)

  calculateScore: (cities) ->
    if @score > 0
      throw "Score already calculated"

    for city in cities
      if city.finished
        added = false
        for tile, fields of city.tiles
          if not added and @tiles[tile] in fields
            added = true
            @score += 3

  toString: ->
    out = "Farm: ("
    for address of @tiles
      out += "#{address}; "
    out.slice(0, -2) + "), size: #{@size}, score: #{@score}"
