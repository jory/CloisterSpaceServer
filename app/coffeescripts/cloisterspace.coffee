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
      north: tile.north
      east:  tile.east
      south: tile.south
      west:  tile.west

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

    if empty(@tiles[address])
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
    out.slice(0, -2) +
        "), size: #{@size}, finished: #{@finished}, numPennants: #{@numPennants}"


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
    @center = parseInt($('#num_tiles').html())
    @maxSize = @center * 2
    @origin = window.location.origin
    @game_id = $('#game_id').html()
    @timeout = 1

    @edges = {}
    haveEdges = false
    @tiles = {}
    haveTiles = false

    haveRoads = false

    @finished = false

    @minrow = @maxrow = @mincol = @maxcol = @center
    @board = (new Array(@maxSize) for i in [1..@maxSize])

    @cloisters = []
    @cities = []
    @roads = []
    @farms = []

    @currentTile = null
    @candidates = []

    getEdges = =>
      $.getJSON("#{@origin}/edges.json", (data) =>
        for obj in data
          edge = obj.edge
          @edges[edge.id] = edge
        haveEdges = true
      )

    getTiles = =>
      if not haveEdges
        setTimeout(getTiles, @timeout)
      else
        $.getJSON("#{@origin}/tiles.json", (data) =>
          for obj in data
            tile = obj.tile
            tile.north = @edges[tile.north]
            tile.south = @edges[tile.south]
            tile.west  = @edges[tile.west]
            tile.east  = @edges[tile.east]
            @tiles[tile.id] = tile
          haveTiles = true
        )

    getFeatures = =>
      $.getJSON("#{@origin}/roads.json", "game=#{@game_id}", (data) =>
        console.log("Got #{data.length} roads")
        for roadFeature in data
          road = new Road()

          for obj in roadFeature
            section = obj.road_section
            road.add(section.x, section.y, section.edge, section.num, section.hasEnd)

          @roads.push(road)

        haveRoads = true
      )


    setupBoard = =>
      if not (haveTiles and haveRoads)
        setTimeout(setupBoard, @timeout)
      else
        url = "#{@origin}/tileInstances.json"
        parameters = "game=#{@game_id}&status=placed"
        $.getJSON(url, parameters, (data) =>
          for obj in data
            instance = obj.tile_instance
            tile = new Tile(@tiles[instance.tile_id], instance.id)
            tile.rotate(instance.rotation)
            @placeTileOnBoard(instance.x, instance.y, tile)
          @drawBoard()
          @next()
        )

    getEdges()
    getTiles()
    getFeatures()
    setupBoard()

  next: ->
    if not @finished
      $.getJSON("#{@origin}/tileInstances/next.json", "game=#{@game_id}", (obj) =>
        if obj?
          instance = obj.tile_instance
          @currentTile = new Tile(@tiles[instance.tile_id], instance.id)
          @candidates = @findValidPositions()
          @drawCandidates()

        else
          @finished = true

          for farm in @farms
            farm.calculateScore(@cities)

          $('#candidate > img').attr('style', 'visibility: hidden')
          $('#left').unbind().prop('disabled', 'disabled')
          $('#right').unbind().prop('disabled', 'disabled')
          $('#step').unbind().prop('disabled', 'disabled')
      )

  findValidPositions: (tile = @currentTile) ->
    candidates = []

    for row in [@minrow - 1..@maxrow + 1]
      for col in [@mincol - 1..@maxcol + 1]
        if empty(@board[row][col])
          for turns in [0..3]
            tile.rotate(turns)

            valid = @validatePosition(row, col, tile)
            if valid?
              candidates.push([row, col, turns, valid])

            tile.reset()

    sortedCandidates = (new Array() for i in [0..3])

    for candidate in candidates
      sortedCandidates[candidate[2]].push(candidate)

    sortedCandidates

  validatePosition: (row, col, tile) ->
    valids = []
    invalids = 0

    for side of adjacents
      [otherRow, otherCol] = offset(side, row, col)
      other = @getTile(otherRow, otherCol)

      if other?
        if tile.connectableTo(side, other)
          valids.push(side)
        else
          invalids++

    if valids.length > 0 and invalids is 0
      return valids

  getTile: (row, col) ->
    if 0 <= row < @maxSize and 0 <= col < @maxSize
      @board[row][col]

  placeTile: (row, col, tile, neighbours) ->
    if neighbours.length is 0 and not tile.isStart
      throw "Invalid tile placement"

    @placeTileOnBoard(row, col, tile)

    @handleCloisters(row, col, tile)
    @handleFarms(row, col, tile, neighbours)
    @handleRoads(row, col, tile, neighbours)
    @handleCities(row, col, tile, neighbours)

    $.ajax(
      url: "#{@origin}/tileInstances/#{tile.id}"
      data: "x=#{row}&y=#{col}&rotation=#{tile.rotation}"
      type: "PUT"
      success: =>
        @next()
    )

  placeTileOnBoard: (row, col, tile) ->
    @board[row][col] = tile

    @maxrow = Math.max(@maxrow, row)
    @minrow = Math.min(@minrow, row)
    @maxcol = Math.max(@maxcol, col)
    @mincol = Math.min(@mincol, col)

  handleCloisters: (row, col, tile) ->
    if tile.isCloister
      cloister = new Cloister(row, col)

      for n, neighbour of cloister.neighbours
        otherRow = neighbour.row
        otherCol = neighbour.col

        if @getTile(otherRow, otherCol)?
          cloister.add(otherRow, otherCol)

      @cloisters.push(cloister)

    for cloister in @cloisters
      if cloister.neighbours[row + "," + col]
        cloister.add(row, col)

  getOtherEdge: (dir, row, col) ->
    [otherRow, otherCol] = offset(dir, row, col)
    [otherRow, otherCol, @getTile(otherRow,otherCol).edges[oppositeDirection[dir]]]

  handleRoads: (row, col, tile, neighbours) ->

    seenRoad = null

    for dir in neighbours
      edge = tile.edges[dir]

      if edge.kind is 'r'

        [otherRow, otherCol, otherEdge] = @getOtherEdge(dir, row, col)
        added = false

        for road in @roads
          if not added and road.has(otherRow, otherCol, otherEdge.road)
            if seenRoad? and not tile.hasRoadEnd
              if road is seenRoad
                # Closing a loop
                road.finished = true
                added = true
              else
                # Merging two roads
                seenRoad.merge(road)
                @roads.remove(road)
                added = true
            else
              # Adding to a road
              road.add(row, col, dir, edge.road, tile.hasRoadEnd)
              seenRoad = road
              added = true

    for dir of adjacents
      if not (dir in neighbours)
        edge = tile.edges[dir]

        if edge.kind is 'r'

          added = false

          for road in @roads
            if not added and road.has(row, col, edge.road)
              road.add(row, col, dir, edge.road, tile.hasRoadEnd)
              added = true

          if not added
              road = new Road()
              road.add(row, col, dir, edge.road, tile.hasRoadEnd)
              @roads.push(road)

  handleCities: (row, col, tile, neighbours) ->
    cities = []

    for dir in neighbours
      edge = tile.edges[dir]
      [otherRow, otherCol, otherEdge] = @getOtherEdge(dir, row, col)
      added = false

      if edge.kind is 'c'
          for city in @cities
            if not added and city.has(otherRow, otherCol, otherEdge.city)
              city.add(row, col, dir, edge.city, tile.cityFields, tile.hasPennant)
              added = true
              if not tile.hasTwoCities and cities.length > 0 and cities[0] isnt city
                cities[0].merge(city)
                @cities.remove(city)
              else
                cities.push(city)

    for dir of adjacents
      if not (dir in neighbours)
        edge = tile.edges[dir]
        added = false

        if edge.kind is 'c'
          for city in @cities
            if not added and city.has(row, col, edge.city)
              city.add(row, col, dir, edge.city, tile.cityFields, tile.hasPennant)
              added = true

          if not added
            c = new City(row, col, dir, edge.city, tile.cityFields, tile.hasPennant)
            @cities.push(c)


  handleFarms: (row, col, tile, neighbours) ->
    farms = []

    for dir in neighbours
      edge = tile.edges[dir]
      [otherRow, otherCol, otherEdge] = @getOtherEdge(dir, row, col)
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

    for dir of adjacents
      if not (dir in neighbours)
        edge = tile.edges[dir]
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

  drawCandidates: (tile = @currentTile, candidates = @candidates) ->
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

  randomlyPlaceTile: (tile = @currentTile, candidates = @candidates) ->
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
          tr.append(td)
      tbody.append(tr)
    $("#board").empty().append(table)


$ ->
  world = new World()

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

  $('#step').click(->
    $('.candidate').unbind().prop('class', '')

    world.randomlyPlaceTile()
    world.drawBoard()
  )

