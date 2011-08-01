class TileInstance < ActiveRecord::Base

  validates :status, :inclusion => { :in => %w(current placed discarded),
                                     :allow_nil => true }

  validates :row, :numericality => { :greater_than => -1, :less_than => 145,
                                     :allow_nil => true }
  validates :col, :numericality => { :greater_than => -1, :less_than => 145,
                                     :allow_nil => true }

  validates :rotation, :inclusion => { :in => 0..3, :allow_nil => true }

  validates :move_number, :numericality =>
    {:allow_nil => true, :only_integer => true, :greater_than => 0}

  validates :tile, :presence => true
  validates :game, :presence => true

  belongs_to :tile
  belongs_to :game

  def initialize(init)
    super(init)
    @neighbours = {}
    @edges = {}    
  end

  def place(row, col, rotation)
    if meets_place_preconditions? row, col, rotation

      @neighbours = find_neighbours(row, col)
      @edges = rotate(rotation)

      if is_valid_placement?
        ##########################################
        # TODO: Figure out why this is a self call when the other ones
        # aren't...
        ##########################################
        if self.update_attributes(:row => row, :col => col, :rotation => rotation,
                                  :status => "placed")
          handleCloisters
          handleRoads
          handleCities
          handleFarms

          game = self.game

          game.move_number += 1

          if game.current_player >= game.players.size
            game.current_player = 1
          else
            game.current_player += 1
          end
          
          game.save

          tiles = game.tileInstances.where(:status => nil)
          
          if tiles.any?
            tile = tiles[rand(tiles.size)]
            tile.status = "current"
            tile.move_number = game.move_number
            tile.save
          end

          return true
        end
      end
    end
  end

  private

  def meets_place_preconditions?(row, col, rotation)
    # TODO: Figure out why this only works when it's self.status,
    # rather than @status.
    if self.status == "placed"
      return false
    end

    if row.nil? or col.nil? or rotation.nil?
      return false
    end

    if not TileInstance.where(:game_id => @game, :row => row, :col => col).empty?
      return false
    end

    return true
  end

  def is_valid_placement?
    if self.tile.isStart
      return true

    elsif @neighbours.empty?
      return false

    else
      @neighbours.each do |dir, tile|

        otherEdges = rotate(tile.rotation)
        
        this = Edge.find(self.tile[@edges[dir]])
        other = Edge.find(tile.tile[otherEdges[Tile::Opposite[dir]]])

        if not this.kind == other.kind
          return false
        end
      end
    end

    return true
  end    
  
  def find_neighbours(row, col)
    n = {}

    north = TileInstance.where(:game_id => self.game, :row => (row - 1), :col => col)
    if not north.empty?
      n[:north] = north.first
    end

    south = TileInstance.where(:game_id => self.game, :row => (row + 1), :col => col)
    if not south.empty?
      n[:south] = south.first
    end

    west = TileInstance.where(:game_id => self.game, :row => row, :col => (col - 1))
    if not west.empty?
      n[:west] = west.first
    end

    east = TileInstance.where(:game_id => self.game, :row => row, :col => (col + 1))
    if not east.empty?
      n[:east] = east.first
    end

    return n
  end

  def rotate(rotation)
    edges = {}
    edges[:north] = :north
    edges[:east]  = :east
    edges[:south] = :south
    edges[:west]  = :west

    rotation.times do
      edges[:north], edges[:east], edges[:south], edges[:west] =
        edges[:west], edges[:north], edges[:east], edges[:south]
    end

    return edges
  end

  def handleCloisters
    if self.tile.isCloister
      cloister = Cloister.create(:row => self.row, :col => self.col, :game => self.game)
      
      (-1..1).each do |dX|
        (-1..1).each do |dY|
          if not (dX == 0 and dY == 0)

            otherRow = self.row + dX
            otherCol = self.col + dY

            if TileInstance.where(:row => otherRow, :col => otherCol,
                                  :game_id => self.game).first
              cloister.add(otherRow, otherCol)
            end
          end
        end
      end
    end

    Cloister.where(:game_id => self.game).each do |cloister|
      if cloister.neighbours(self.row, self.col)
        cloister.add(self.row, self.col)
      end
    end
  end

  ##########################################
  # TODO: Figure out why the query needs to be Road.where,
  # instead of the other form.
  # 
  # Also TODO: Refactor this method like crazy!
  #            (Specifically the layout)
  ##########################################
  def handleRoads

    seenRoad = nil
    
    @neighbours.each { |dir, tile|
      edge = Edge.find(self.tile[@edges[dir]])

      if edge.kind == 'r'
        
        otherRow, otherCol = Tile.getAddress(self.row, self.col, dir)
        otherEdge = Edge.find(tile.tile[rotate(tile.rotation)[Tile::Opposite[dir]]])

        Road.where(:game_id => self.game).each do |road|
          if road.has(otherRow, otherCol, otherEdge.road)
            if not seenRoad.nil? and not self.tile.hasRoadEnd
              if road == seenRoad
                road.finished = true
                road.save
              else
                seenRoad.merge(road)
              end
            else
              road.add(self.row, self.col, dir, edge.road, self.tile.hasRoadEnd)
              seenRoad = road
            end
            
            break

          end
        end
      end
    }

    Tile::Directions.each { |dir|
      if not @neighbours[dir]

        edge = Edge.find(self.tile[@edges[dir]])
        if edge.kind == 'r'

          added = false
          
          Road.where(:game_id => self.game).each do |road|
            if road.has(self.row, self.col, edge.road)
              road.add(self.row, self.col, dir, edge.road, self.tile.hasRoadEnd)
              added = true
              break
            end
          end

          if not added
            road = Road.create(:game => self.game)
            if not road.add(self.row, self.col, dir, edge.road, self.tile.hasRoadEnd)
              raise "Failed to add to the road."
            end
          end
        end
      end
    }
  end

  def handleCities
    seenCity = nil

    @neighbours.each do |dir, tile|
      edge = Edge.find(self.tile[@edges[dir]])

      if edge.kind == 'c'

        otherRow, otherCol = Tile.getAddress(self.row, self.col, dir)
        otherEdge = Edge.find(tile.tile[rotate(tile.rotation)[Tile::Opposite[dir]]])

        City.where(:game_id => self.game).each do |city|
          if city.has(otherRow, otherCol, otherEdge.city)

            city.add(row, col, dir, edge.city, self.tile.citysFields,
                     self.tile.hasPennant)

            if not seenCity.nil? and not self.tile.hasTwoCities
              seenCity.merge(city)
            else
              seenCity = city
            end

            break
          end
        end
      end
    end

    Tile::Directions.each do |dir|
      if not @neighbours[dir]

        edge = Edge.find(self.tile[@edges[dir]])

        if edge.kind == 'c'

          added = false
          
          City.where(:game_id => self.game).each do |city|
            if city.has(self.row, self.col, edge.city)
              city.add(self.row, self.col, dir, edge.city,
                       self.tile.citysFields, self.tile.hasPennant)
              added = true
              break
            end
          end

          if not added
            city = City.create(:game => self.game)
            city.add(self.row, self.col, dir, edge.city,
                     self.tile.citysFields, self.tile.hasPennant)
          end
        end
      end
    end
  end

  def handleFarms
    seenFarms = []

    @neighbours.each do |dir, tile|
      edge = Edge.find(self.tile[@edges[dir]])
      otherRow, otherCol = Tile.getAddress(self.row, self.col, dir)
      otherEdge = Edge.find(tile.tile[rotate(tile.rotation)[Tile::Opposite[dir]]])

      if edge.grassA != 0
        added = false
        
        Farm.where(:game_id => self.game).each do |farm|
          if farm.has(otherRow, otherCol, otherEdge.grassB)
            if seenFarms.length > 0
              seenFarms.each do |otherFarm|
                if otherFarm.has(self.row, self.col, edge.grassA)
                  otherFarm.add(self.row, self.col, dir, edge.grassA)
                  otherFarm.merge(farm)
                  added = true
                  break
                end
              end
            end

            if not added
              farm.add(self.row, self.col, dir, edge.grassA)
              seenFarms.push(farm)
            end

            break
          end
        end
      end

      if edge.grassB != 0
        added = false
        
        Farm.where(:game_id => self.game).each do |farm|
          if farm.has(otherRow, otherCol, otherEdge.grassA)
            if seenFarms.length > 0
              seenFarms.each do |otherFarm|
                if otherFarm.has(self.row, self.col, edge.grassB)
                  otherFarm.add(self.row, self.col, dir, edge.grassB)
                  otherFarm.merge(farm)
                  added = true
                  break
                end
              end
            end

            if not added
              farm.add(self.row, self.col, dir, edge.grassB)
              seenFarms.push(farm)
            end

            break
          end
        end
      end
    end

    Tile::Directions.each do |dir|
      if not @neighbours[dir]
        edge = Edge.find(self.tile[@edges[dir]])

        if edge.grassA != 0
          added = false
          
          Farm.where(:game_id => self.game).each do |farm|
            if farm.has(self.row, self.col, edge.grassA)
              farm.add(self.row, self.col, dir, edge.grassA)
              added = true
              break
            end
          end

          if not added
            farm = Farm.create(:game => self.game)
            farm.add(self.row, self.col, dir, edge.grassA)
          end
        end

        if edge.grassB != 0
          added = false
          
          Farm.where(:game_id => self.game).each do |farm|
            if farm.has(self.row, self.col, edge.grassB)
              farm.add(self.row, self.col, dir, edge.grassB)
              added = true
              break
            end
          end

          if not added
            farm = Farm.create(:game => self.game)
            farm.add(self.row, self.col, dir, edge.grassB)
          end
        end
      end
    end
  end
  
end
