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


class Tile
  constructor: (tile, @id = null) ->
    @image = tile.image

    @hasTwoCities = tile.hasTwoCities
    @hasRoadEnd = tile.hasRoadEnd
    @hasPennant = tile.hasPennant
    @citysFields = tile.citysFields
    @isCloister = tile.isCloister
    @isStart = tile.isStart

    @edges =
      north: tile.northEdge
      east:  tile.eastEdge
      south: tile.southEdge
      west:  tile.westEdge

    @rotation = 0
    @rotationClass = 'r0'

  rotate: (turns) ->
    if turns not in [-3..3]
      throw 'Invalid Rotation'

    if turns isnt 0
      switch turns
        when -1 then turns = 3
        when -2 then turns = 2
        when -3 then turns = 1

      @rotation += turns
      @rotation -= 4 if @rotation > 3

      @rotationClass = "r#{@rotation}"

      for i in [1..turns]
        tmp = @edges.north
        @edges.north = @edges.west
        @edges.west  = @edges.south
        @edges.south = @edges.east
        @edges.east  = tmp

  reset: ->
    @rotate(4 - @rotation) if @rotation > 0

  connectableTo: (from, other) ->
    @edges[from].kind is other.edges[oppositeDirection[from]].kind


class Road
  constructor: (row, col, edge, id, hasEnd) ->
    @tiles = {}
    @ids = {}
    @edges = {}
    @length = 0
    @numEnds = 0
    @finished = false

    @add(row, col, edge, id, hasEnd)

  add: (row, col, edge, id, hasEnd) ->
    address = "#{row},#{col}"

    if not @tiles[address]
      @length += 1
      @tiles[address] = true

    @ids[address + ",#{id}"] = true

    @edges[address + ",#{edge}"] =
      row: row
      col: col
      edge: edge
      id: id
      hasEnd: hasEnd

    if hasEnd
      @numEnds += 1
      if @numEnds is 2
        @finished = true

  has: (row, col, id) ->
    @ids["#{row},#{col},#{id}"]

  merge: (other) ->
    for e, edge of other.edges
      @add(edge.row, edge.col, edge.edge, edge.id, edge.hasEnd)

  toString: ->
    out = "Road: ("
    for address of @tiles
      out += "#{address}; "
    out.slice(0, -2) + "), length: #{@length}, finished: #{@finished}, numEnds: #{@numEnds}"


class City
  constructor: (row, col, edge, id, citysFields, hasPennant) ->
    @tiles = {}
    @ids = {}
    @edges = {}
    @openEdges = []
    @size = 0
    @numPennants = 0
    @finished = false

    @add(row, col, edge, id, citysFields, hasPennant)

  add: (row, col, edge, id, citysFields, hasPennant) ->
    address = "#{row},#{col}"

    if not @tiles[address]?
      @tiles[address] = citysFields
      @size += 1
      if hasPennant
        @numPennants += 1

    @ids[address + ",#{id}"] = true

    @edges[address + ",#{edge}"] =
      row: row
      col: col
      edge: edge
      id: id

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

  has: (row, col, id) ->
    @ids["#{row},#{col},#{id}"]

  merge: (other) ->
    for e, edge of other.edges
      row = edge.row
      col = edge.col
      @add(row, col, edge.edge, edge.id, other.tiles["#{row},#{col}"], false)
    @numPennants += other.numPennants

  toString: ->
    out = "City: ("
    for address of @tiles
      out += "#{address}; "
    out.slice(0, -2) + "), size: #{@size}, finished: #{@finished}, numPennants: #{@numPennants}"


class Cloister
  constructor: (row, col) ->
    @tiles = {}
    @neighbours = {}
    @size = 0
    @finished = false

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


class Farm
  constructor: (row, col, edge, id) ->
    @tiles = {}
    @ids = {}
    @edges = {}
    @size = 0
    @score = 0

    @add(row, col, edge, id)

  add: (row, col, edge, id) ->
    address = "#{row},#{col}"

    if not @tiles[address]
      @tiles[address] = id
      @size += 1

    @ids[address + ",#{id}"] = true

    @edges[address + ",#{edge}"] =
      row: row
      col: col
      edge: edge
      id: id

  has: (row, col, id) ->
    @ids["#{row},#{col},#{id}"]

  merge: (other) ->
    for e, edge of other.edges
      @add(edge.row, edge.col, edge.edge, edge.id)

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

class World
  constructor: ->
    @center = @minrow = @maxrow = @mincol = @maxcol = parseInt($('#num_tiles').html())
    @maxSize = @center * 2
    @board = (new Array(@maxSize) for i in [1..@maxSize])

    @cloisters = []
    @cities = []
    @roads = []
    @farms = []

    @tiles = {}
    @edges = {}

    @origin = window.location.origin
    @game_id = $('#game_id').html()
    @timeout = 1

    setupBoard = =>
      haveEdges = false
      count = 0
      total = -1

      getEdges = =>
        $.getJSON("#{@origin}/edges.json", (data) =>
          for obj in data
            edge = obj.edge
            @edges[edge.id] = edge

          haveEdges = true
        )

      createTile = (instance) =>
        id = instance.tile_id

        createTileHelper = =>
          if not @tiles[id]?
            setTimeout(createTileHelper, @timeout)
          else
            tile = new Tile(@tiles[id], instance.id)
            tile.rotate(instance.rotation)
            @barePlaceTile(instance.x, instance.y, tile)
            count += 1

        createTileHelper()

      draw = =>
        if count isnt total
          setTimeout(draw, @timeout)
        else
          @drawBoard()
          @next()

      getTileInstances = =>
        if not haveEdges
          setTimeout(getTileInstances, @timeout)
        else
          $.getJSON("#{@origin}/tileInstances.json", "game=#{@game_id}&status=placed", (data) =>

            total = data.length
            count = 0

            for obj in data
              tile_instance = obj.tile_instance
              id = tile_instance.tile_id

              if not @tiles[id]?
                @getTile(id)

              createTile(tile_instance)
          )

      getEdges()
      getTileInstances()
      draw()

    setupBoard()

  getTile: (id) =>
    $.getJSON("#{@origin}/tiles/#{id}.json", (data) =>
      tile = data.tile
      tile.northEdge = @edges[tile.northEdge]
      tile.southEdge = @edges[tile.southEdge]
      tile.westEdge  = @edges[tile.westEdge]
      tile.eastEdge  = @edges[tile.eastEdge]
      @tiles[id] = tile
    )

  barePlaceTile: (row, col, tile) ->
    @board[row][col] = tile

    @maxrow = Math.max(@maxrow, row)
    @minrow = Math.min(@minrow, row)
    @maxcol = Math.max(@maxcol, col)
    @mincol = Math.min(@mincol, col)

  next: ->
    findPositions = (instance) =>
      tile_id = instance.tile_id

      findPositionsHelper = =>
        if not @tiles[tile_id]?
          setTimeout(findPositionsHelper, @timeout)
        else
          tile = new Tile(@tiles[tile_id], instance.id)
          candidates = @findValidPositions(tile)
          @drawCandidates(tile, candidates)

      findPositionsHelper()

    $.getJSON("#{@origin}/tileInstances.json", "game=#{@game_id}&status=current", ([obj]) =>
      if obj?
        instance = obj.tile_instance
        id = instance.tile_id

        if not @tiles[id]?
          @getTile(id)

        findPositions(instance)

      else
        $('#candidate > img').attr('style', 'visibility: hidden')
        $('#left').unbind().prop('disabled', 'disabled')
        $('#right').unbind().prop('disabled', 'disabled')

        for farm in @farms
          farm.calculateScore(@cities)
    )

  findValidPositions: (tile) ->
    candidates = []

    for row in [@minrow - 1..@maxrow + 1]
      for col in [@mincol - 1..@maxcol + 1]
        if not @board[row][col]?
          for turns in [0..3]

            tile.rotate(turns)

            valids = []
            invalids = 0

            for side of adjacents
              [otherRow, otherCol] = offset(side, row, col)

              if 0 <= otherRow < @maxSize and 0 <= otherCol < @maxSize
                other = @board[otherRow][otherCol]
                if other?
                  if tile.connectableTo(side, other)
                    valids.push(side)
                  else
                    invalids++

            if valids.length > 0 and invalids is 0
              candidates.push([row, col, turns, valids])

            tile.reset()

    sortedCandidates = (new Array() for i in [0..3])

    for candidate in candidates
      sortedCandidates[candidate[2]].push(candidate)

    sortedCandidates

  randomlyPlaceTile: (tile, candidates) ->
    candidates = [].concat candidates...

    if candidates.length > 0
      subcandidates = (new Array() for i in [0..4])

      for candidate in candidates
        subcandidates[candidate[3].length].push(candidate)

      index = 0
      for i in [0..4]
        if subcandidates[i].length > 0
          index = i

      j = Math.round(Math.random() * (subcandidates[index].length - 1))
      [row, col, turns, neighbours] = subcandidates[index][j]

      tile.rotate(turns) if turns > 0

      @placeTile(row, col, tile, neighbours)

  drawBoard: ->
    table = $("<table><tbody></tbody></table>")
    tbody = table.find("tbody")

    for row in [@minrow - 1..@maxrow + 1]
      tr = $("<tr row='#{row}'></tr>")
      for col in [@mincol - 1..@maxcol + 1]
        if 0 <= row < @maxSize and 0 <= col < @maxSize
          td = $("<td row='#{row}' col='#{col}'></td>")
          tile = @board[row][col]
          if tile?
            td = $("<td row='#{row}' col='#{col}'>" +
                   "<img src='/images/#{tile.image}' class='#{tile.rotationClass}'/></td>")
            # TODO: Remove this!
            if tile.isStart
              td.prop('class', 'debug')
          tr.append(td)
      tbody.append(tr)
    $("#board").empty().append(table)

  drawCandidates: (tile, candidates) ->
    img = $('#candidate > img').attr('src', "/images/#{tile.image}")
    img.attr('class', tile.rotationClass).attr('style', '')

    disableAll = ->
      for item in actives
        item.prop('class', '').unbind()

      $('#left').unbind().prop('disabled', 'disabled')
      $('#right').unbind().prop('disabled', 'disabled')

    attach = (cell, row, col, neighbours) =>
      cell.unbind().click(=>
        disableAll()
        @placeTile(row, col, tile, neighbours)
        @drawBoard()

        # Add clicking here!
        # <map...>

        $.ajax(
          url: "#{@origin}/tileInstances/#{tile.id}"
          data: "x=#{row}&y=#{col}&rotation=#{tile.rotation}"
          type: "PUT"
          success: =>
            @next()
        )
      ).prop('class', 'candidate')

    actives = for candidate in candidates[tile.rotation]
      [row, col, turns, neighbours] = candidate
      attach($("td[row=#{row}][col=#{col}]"), row, col, neighbours)

    $('#left').unbind().click(=>
      disableAll()
      tile.rotate(-1)
      @drawCandidates(tile, candidates)
    ).prop('disabled', '')

    $('#right').unbind().click(=>
      disableAll()
      tile.rotate(1)
      @drawCandidates(tile, candidates)
    ).prop('disabled', '')

  placeTile: (row, col, tile, neighbours) ->
    if neighbours.length is 0 and not tile.isStart
      throw "Invalid tile placement"

    @board[row][col] = tile

    @maxrow = Math.max(@maxrow, row)
    @minrow = Math.min(@minrow, row)
    @maxcol = Math.max(@maxcol, col)
    @mincol = Math.min(@mincol, col)

    # Connect the features of the current tile to the world-level features.
    #
    # - Cloisters operate on the tile level, rather than the edge level.
    #
    # Keeping track of roads, cities and farms (per edge):
    #
    #  - every city edge must be connected to another city edge. If any
    #    city edge is unconnected (i.e. singular), the city can't be complete
    #
    #  - roads must have two ends (or make a fully closed loop)
    #
    #  - farms... are complicated
    #    - have to handle the grass type edge, but also have to handle the
    #      grass on each individual edge.

    if tile.isCloister
      cloister = new Cloister(row, col)

      for n, neighbour of cloister.neighbours
        if 0 <= neighbour.row < @maxSize and 0 <= neighbour.col < @maxSize
          if @board[neighbour.row][neighbour.col]?
            cloister.add(neighbour.row, neighbour.col)

      @cloisters.push(cloister)

    for cloister in @cloisters
      if cloister.neighbours[row + "," + col]
        cloister.add(row, col)

    handled =
      north: false
      south: false
      east:  false
      west:  false

    farms = []
    roads = []
    cities = []

    for dir in neighbours
      edge = tile.edges[dir]

      [otherRow, otherCol] = offset(dir, row, col)
      otherTile = @board[otherRow][otherCol]
      otherEdge = otherTile.edges[oppositeDirection[dir]]

      # Add to the existings farms, if applicable.

      added = false

      if edge.grassA isnt '-'
        for farm in @farms
          if not added and farm.has(otherRow, otherCol, otherEdge.grassB)

            if farms.length > 0
              for otherFarm in farms
                if not added and otherFarm.has(row, col, edge.grassA)
                  if otherFarm isnt farm
                    otherFarm.add(row, col, dir, edge.grassA)
                    otherFarm.merge(farm)
                    @farms.remove(farm)
                    added = true

            if not added
              farm.add(row, col, dir, edge.grassA)
              farms.push(farm)
              added = true

      added = false

      if edge.grassB isnt '-'
        for farm in @farms
          if not added and farm.has(otherRow, otherCol, otherEdge.grassA)

            if farms.length > 0
              for otherFarm in farms
                if not added and otherFarm.has(row, col, edge.grassB)
                  if otherFarm isnt farm
                    otherFarm.add(row, col, dir, edge.grassB)
                    otherFarm.merge(farm)
                    @farms.remove(farm)
                    added = true

            if not added
              farm.add(row, col, dir, edge.grassB)
              farms.push(farm)
              added = true

      # Add to whatever other existing feature is on the edge.

      added = false

      if edge.type is 'road'
        if not tile.hasRoadEnd and roads.length > 0
          for road in @roads
            if not added and road.has(otherRow, otherCol, otherEdge.road)
              if roads[0] is road
                # Closing a loop
                road.finished = true
                added = true
              else
                # Merging two roads
                roads[0].merge(road)
                @roads.remove(road)
                added = true
        else
          for road in @roads
            if not added and road.has(otherRow, otherCol, otherEdge.road)
              road.add(row, col, dir, edge.road, tile.hasRoadEnd)
              roads.push(road)
              added = true

      else if edge.type is 'city'
        if not tile.hasTwoCities and cities.length > 0
          for city in @cities
            if not added and city.has(otherRow, otherCol, otherEdge.city)

              city.add(row, col, dir, edge.city, tile.citysFields, tile.hasPennant)
              added = true

              if cities[0] isnt city
                cities[0].merge(city)
                @cities.remove(city)

        else
          # If you are adding a tile with two cities, or you do not
          # yet have a merge candidate, you do not need to perform a
          # merge.
          for city in @cities
            if not added and city.has(otherRow, otherCol, otherEdge.city)
              city.add(row, col, dir, edge.city, tile.citysFields, tile.hasPennant)
              cities.push(city)
              added = true

      handled[dir] = true

    for dir, seen of handled
      if not seen
        edge = tile.edges[dir]

        # either attach my features to existing ones on the current tile,
        # or create new features.

        added = false

        if edge.grassA isnt '-'
          for farm in @farms
            if not added and farm.has(row, col, edge.grassA)
              farm.add(row, col, dir, edge.grassA)
              added = true

          if not added
            @farms.push(new Farm(row, col, dir, edge.grassA))

        added = false

        if edge.grassB isnt '-'
          for farm in @farms
            if not added and farm.has(row, col, edge.grassB)
              farm.add(row, col, dir, edge.grassB)
              added = true

          if not added
            @farms.push(new Farm(row, col, dir, edge.grassB))

        added = false

        if edge.type is 'road'
          for road in @roads
            if not added and road.has(row, col, edge.road)
              road.add(row, col, dir, edge.road, tile.hasRoadEnd)
              added = true

          if not added
              @roads.push(new Road(row, col, dir, edge.road, tile.hasRoadEnd))

        else if edge.type is 'city'
          for city in @cities
            if not added and city.has(row, col, edge.city)
              city.add(row, col, dir, edge.city, tile.citysFields, tile.hasPennant)
              added = true

          if not added
            @cities.push(new City(row, col, dir, edge.city, tile.citysFields, tile.hasPennant))


print_features = (all) ->
  console.log('------------------------------------------')

  for cloister in world.cloisters
    if all or cloister.finished
      console.log(cloister.toString())

  for city in world.cities
    if all or city.finished
      console.log(city.toString())

  for road in world.roads
    if all or road.finished
      console.log(road.toString())

  for farm in world.farms
    console.log(farm.toString())

$ ->
  world = new World()

  $('#features_all').click(->
    print_features(true)
  )

  $('#features_completed').click(->
    print_features(false)
  )

  $('#features_farms').click(->
    console.log('------------------------------------------')

    for farm in world.farms
      console.log(farm.toString())
  )

  $('#go').click(->
    $('.candidate').unbind().prop('class', '')

    for tile in world.tiles
      world.randomlyPlaceTile(tile, world.findValidPositions(tile))

    world.tiles = []

    $('#candidate > img').attr('style', 'visibility: hidden')
    $('#left').unbind().prop('disabled', 'disabled')
    $('#right').unbind().prop('disabled', 'disabled')

    $('#go').unbind().prop('disabled', 'disabled')
    $('#step').unbind().prop('disabled', 'disabled')

    for farm in world.farms
      farm.calculateScore(world.cities)

    world.drawBoard()
  )

  $('#step').click(->
    $('.candidate').unbind().prop('class', '')

    tile = world.tiles.shift()
    world.randomlyPlaceTile(tile, world.findValidPositions(tile))

    world.drawBoard()
    world.next()

    print_features(true)

    if world.tiles.length is 0
      $('#go').unbind().prop('disabled', 'disabled')
      $('#step').unbind().prop('disabled', 'disabled')
  )

  $('#draw').click(->
    world.drawBoard()
  )
