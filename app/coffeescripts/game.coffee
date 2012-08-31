class Game
  constructor: ->
    @players_turn = parseInt($('#players_turn').text())
    @players_colour = $('#players_colour').text()

    @origin = window.location.protocol + "//" + window.location.host
    @href = window.location.href + "/"

    @finished = false

    @edges = {}
    @tiles = {}

    @center = parseInt($('#num_tiles').text())
    @maxSize = @center * 2
    @minrow = @maxrow = @mincol = @maxcol = @center
    @board = (new Array(@maxSize) for i in [1..@maxSize])

    @cloisters = []
    @cities = []
    @roads = []
    @farms = []

    @currentPlayer = -1
    @currentMoveNumber = -1
    @currentTile = null

    @candidates = []

    parseEdges = =>
      data = $.parseJSON($('#json_edges').text())

      for obj in data
        edge = obj.edge
        @edges[edge.id] = edge

    parseTiles = =>
      data = $.parseJSON($('#json_tiles').text())

      for obj in data
        tile = obj.tile
        tile.north = @edges[tile.north]
        tile.south = @edges[tile.south]
        tile.west  = @edges[tile.west]
        tile.east  = @edges[tile.east]
        @tiles[tile.id] = tile

    setupBoard = =>
      data = $.parseJSON($('#json_placed_tiles').text())

      @currentMoveNumber = data.length

      for obj in data
        instance = obj.tile_instance
        tile = new Tile(@tiles[instance.tile_id], instance.id)
        tile.rotate(instance.rotation)
        @placeTileOnBoard(instance.row, instance.col, tile)

      @drawBoard()

    drawInterface = =>
      num_unused_meeples = parseInt($('#num_unused_meeples').text())

      for i in [1..num_unused_meeples]
        $('#meeples').append("<img src='/images/meeples/#{@players_colour}.gif'/>")

    parseRoads = =>
      data = $.parseJSON($('#json_roads').text())

      for roadFeature in data
        road = new Road()

        for obj in roadFeature
          section = obj.road_section
          road.add(section.row, section.col, section.edge, section.num,
                   section.hasEnd)

        @roads.push(road)

    parseCities = =>
      data = $.parseJSON($('#json_cities').text())

      for cityFeature in data
        city = new City()

        for obj in cityFeature
          section = obj.city_section
          city.add(section.row, section.col, section.edge, section.num,
                   section.citysFields, section.hasPennant)

        @cities.push(city)

    parseFarms = =>
      data = $.parseJSON($('#json_farms').text())

      for farmFeature in data
        farm = new Farm()

        for obj in farmFeature
          section = obj.farm_section
          farm.add(section.row, section.col, section.edge, section.num)

        @farms.push(farm)

    parseCloisters = =>
      data = $.parseJSON($('#json_cloisters').text())

      for obj in data
        c = obj[0].cloister
        cloister = new Cloister(c.row, c.col)

        for section in obj[1]
          cs = section.cloister_section
          cloister.add(cs.row, cs.col)

        @cloisters.push(cloister)


    parseEdges()
    parseTiles()

    drawInterface()
    setupBoard()

    parseRoads()
    parseCities()
    parseFarms()
    parseCloisters()

    @next()

  next: ->
    if not @finished
      $.getJSON(@href + "next.json", (obj) =>
        if obj?
          instance = obj[1].tile_instance

          @currentPlayer = obj[0]
          @currentMoveNumber += 1
          @currentTile = new Tile(@tiles[instance.tile_id], instance.id)

          $('.current_player').removeClass('current_player');
          player = $('#player_' + @currentPlayer).addClass('current_player');

          info_turn = $('#info_turn').empty()
          if @currentPlayer == @players_turn
            info_turn.append("YOUR")
          else
            info_turn.append(player.find('td[class="player_email"]').text() + "'s")


          @candidates = @findValidPositions()
          @drawCandidates()

          if @currentPlayer != @players_turn
            @getNextMove()

        else
          @finished = true

          for farm in @farms
            farm.calculateScore(@cities)

          $('#candidate > img').attr('style', 'visibility: hidden')
          $('#left').unbind()
          $('#right').unbind()
          $('#step').unbind().prop('disabled', 'disabled')
      )

  getNextMove: ->
    helper = =>
      $.getJSON(@href + "move/#{@currentMoveNumber}.json", (obj) =>
        if not obj?
          setTimeout(helper, 1000)
        else
          $('#candidate > img').attr('style', 'visibility: hidden')

          inst = obj.tile_instance

          for candidate in @candidates[inst.rotation]
            if candidate[0] == inst.row and candidate[1] == inst.col
              @currentTile.reset()
              @currentTile.rotate(inst.rotation)
              @placeTile(inst.row, inst.col, @currentTile, candidate[3])

          @drawBoard()
          @next()
      )

    helper()

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

    # This bit of code should be associated with clicking on confirm,
      # rather than being in placeTile.
    if @currentPlayer == @players_turn
      $.ajax(
        url: @href + "tileInstances/place/#{tile.id}"
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
              city.add(row, col, dir, edge.city, tile.citysFields, tile.hasPennant)
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
              city.add(row, col, dir, edge.city, tile.citysFields, tile.hasPennant)
              added = true

          if not added
            c = new City()
            c.add(row, col, dir, edge.city, tile.citysFields, tile.hasPennant)
            @cities.push(c)


  handleFarms: (row, col, tile, neighbours) ->
    farms = []

    for dir in neighbours
      edge = tile.edges[dir]
      [otherRow, otherCol, otherEdge] = @getOtherEdge(dir, row, col)
      added = false

      if edge.grassA isnt 0
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

      if edge.grassB isnt 0
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

        if edge.grassA isnt 0
          for farm in @farms
            if not added and farm.has(row, col, edge.grassA)
              farm.add(row, col, dir, edge.grassA)
              added = true

          if not added
            f = new Farm()
            f.add(row, col, dir, edge.grassA)
            @farms.push(f)

        added = false

        if edge.grassB isnt 0
          for farm in @farms
            if not added and farm.has(row, col, edge.grassB)
              farm.add(row, col, dir, edge.grassB)
              added = true

          if not added
            f = new Farm()
            f.add(row, col, dir, edge.grassB)
            @farms.push(f)

  drawCandidates: (tile = @currentTile, candidates = @candidates) ->
    img = $('#candidate > img').attr('src', "/images/#{tile.image}")
    img.attr('class', tile.rotationClass).attr('style', '')

    disableAll = ->
      for item in actives
        item.removeClass('candidate-active').removeClass('candidate-inactive').unbind()

      $('#left').unbind()
      $('#right').unbind()

      $('#confirm').unbind().prop('disabled', 'disabled')
      $('#undo').unbind().prop('disabled', 'disabled')

    attach = (cell, row, col, neighbours) =>
      cell.unbind().click(=>
        disableAll()
        img.attr('style', 'visibility: hidden')

        $("div[row=#{row}][col=#{col}]").append("<img " +
            "src='/images/#{tile.image}' class='#{tile.rotationClass}'/>")

        $('#confirm').click(=>
          $('#confirm').unbind().prop('disabled', 'disabled')
          $('#undo').unbind().prop('disabled', 'disabled')
          @placeTile(row, col, tile, neighbours)
          @drawBoard()
        ).prop('disabled', '')


        $('#undo').click(=>
          $('#confirm').unbind().prop('disabled', 'disabled')
          $('#undo').unbind().prop('disabled', 'disabled')
          @drawBoard()
          @drawCandidates()
        ).prop('disabled', '')

        # Add clicking here!
        # <map...>

      )

    actives = for candidate in candidates[tile.rotation]
      [row, col, turns, neighbours] = candidate
      cell = $("div[row=#{row}][col=#{col}]")

      if @currentPlayer == @players_turn
        cell.addClass('candidate-active')
        attach(cell, row, col, neighbours)
      else
        cell.addClass('candidate-inactive')

    $('#left').unbind().click(=>
      disableAll()
      tile.rotate(-1)
      @drawCandidates()
    )

    $('#right').unbind().click(=>
      disableAll()
      tile.rotate(1)
      @drawCandidates()
    )

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
    div = $("#board").empty()

    for row in [@minrow - 1..@maxrow + 1]
      tr = $("<div class='row' row='#{row}'></div>")
      for col in [@mincol - 1..@maxcol + 1]
        if 0 <= row < @maxSize and 0 <= col < @maxSize
          td = $("<div class='col' row='#{row}' col='#{col}'></div>")
          tile = @board[row][col]
          if tile?
            td.append("<img src='/images/#{tile.image}'" +
                           "class='#{tile.rotationClass}'/>")
          tr.append(td)
      div.append(tr)
