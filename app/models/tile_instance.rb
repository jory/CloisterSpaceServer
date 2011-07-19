class TileInstance < ActiveRecord::Base

  validates :status, :inclusion => { :in => %w(current placed discarded),
                                     :allow_nil => true }

  validates :row, :numericality => { :greater_than => -1, :less_than => 145,
                                     :allow_nil => true }
  validates :col, :numericality => { :greater_than => -1, :less_than => 145,
                                     :allow_nil => true }

  validates :rotation, :inclusion => { :in => 0..3, :allow_nil => true }

  validates :tile, :presence => true
  validates :game, :presence => true

  belongs_to :tile
  belongs_to :game

  @@Opposite = {}
  @@Opposite[:north] = :south
  @@Opposite[:south] = :north
  @@Opposite[:east]  = :west
  @@Opposite[:west]  = :east

  @@Directions = @@Opposite.keys
  
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
        end
      end
    end
  end

  def TileInstance.next(game_id)
    current = TileInstance.where(:game_id => game_id, :status => "current") 

    if not current.empty?
      return current.first
    end
    
    tiles = TileInstance.where(:game_id => game_id, :status => nil)

    if not tiles.empty?
      tile = tiles[rand(tiles.size)]
      tile.status = "current"
      tile.save
      return tile
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
        other = Edge.find(tile.tile[otherEdges[@@Opposite[dir]]])

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
    else
      Cloister.where(:game_id => self.game).each do |cloister|
        if cloister.neighbours(self.row, self.col)
          cloister.add(self.row, self.col)
        end
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
        
        otherRow, otherCol = offset(self.row, self.col, dir)
        otherEdge = Edge.find(tile.tile[rotate(tile.rotation)[@@Opposite[dir]]])

        Road.where(:game_id => self.game).each do |road|
          if road.has(otherRow, otherCol, otherEdge.road)
            if not seenRoad.nil? and not self.tile.hasRoadEnd
              if road == seenRoad
                road.finished = true
                road.save
              else
                seenRoad.merge(road)
                road.delete
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

    @@Directions.each { |dir|
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

  def offset(row, col, dir)
    if dir == :north    then return row - 1, col
    elsif dir == :south then return row + 1, col
    elsif dir == :east  then return row, col + 1
    elsif dir == :west  then return row, col - 1
    end
  end
  
end
