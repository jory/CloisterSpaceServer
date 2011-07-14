class TileInstance < ActiveRecord::Base

  validates :status, :inclusion => { :in => ["current", "placed", "discarded"],
                                     :allow_nil => true }

  validates :x, :numericality => { :greater_than => -1, :less_than => 145,
                                   :allow_nil => true }
  validates :y, :numericality => { :greater_than => -1, :less_than => 145,
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
  
  def place(x, y, rotation)

    if not meets_place_preconditions? x, y, rotation
      return false
    end

    if is_valid_placement? x, y, rotation
      self.x = x
      self.y = y
      self.rotation = rotation
      self.status = "placed"
      self.save
    else
      return false
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

  def meets_place_preconditions?(x, y, rotation)
    if self.status == "placed"
      return false
    end

    if x.nil? or y.nil? or rotation.nil?
      return false
    end

    if not TileInstance.where(:game_id => self.game, :x => x, :y => y).empty?
      return false
    end

    return true
  end

  def is_valid_placement?(x, y, rotation)
    valid = false
    
    if self.tile.isStart
      valid = true
    else
      neighbours = find_neighbours(x, y)
      if not neighbours.empty?

        valid = true
        edges = rotate(rotation)
        
        neighbours.each do |dir, tile|

          otherEdges = rotate(tile.rotation)
          
          this = Edge.find(self.tile[edges[dir].to_s + "Edge"])
          other = Edge.find(tile.tile[otherEdges[@@Opposite[dir]].to_s + "Edge"])

          if not this.kind == other.kind
            valid = false
            break
          end
        end
      end
    end

    return valid
  end    
  
  def find_neighbours(x, y)
    n = {}

    north = TileInstance.where(:game_id => self.game, :x => (x - 1), :y => y)
    if not north.empty?
      n[:north] = north.first
    end

    south = TileInstance.where(:game_id => self.game, :x => (x + 1), :y => y)
    if not south.empty?
      n[:south] = south.first
    end

    west = TileInstance.where(:game_id => self.game, :x => x, :y => (y - 1))
    if not west.empty?
      n[:west] = west.first
    end

    east = TileInstance.where(:game_id => self.game, :x => x, :y => (y + 1))
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
  
end
