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
