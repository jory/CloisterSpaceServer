class TileInstance < ActiveRecord::Base

  belongs_to :tile
  belongs_to :game

  validates :status, :inclusion => { :in => ["current", "placed", "discarded"],
                                     :allow_nil => true }
  validates :x, :numericality => { :greater_than => -1,
                                   :less_than => 145,
                                   :allow_nil => true }
  validates :y, :numericality => { :greater_than => -1,
                                   :less_than => 145,
                                   :allow_nil => true }
  validates :rotation, :inclusion => { :in => 0..3, :allow_nil => true }
  validates :tile, :presence => true
  validates :game, :presence => true

  def place(x, y, rotation)

    if self.status == "placed"
      return false
    end

    if x.nil? or y.nil? or rotation.nil?
      return false
    end

    if not TileInstance.where(:game_id => self.game, :x => x, :y => y).empty?
      return false
    end

    valid = false
    
    if self.tile.isStart
      valid = true
    end

    neighbours = find_neighbours(x, y)

    if not neighbours.empty?
      valid = true

      opposite = {}
      opposite['north'] = 'south'
      opposite['south'] = 'north'
      opposite['east']  = 'west'
      opposite['west']  = 'east'
      
      neighbours.each do |dir, tile|

        my = Edge.find(self.tile[dir + "Edge"])
        your = Edge.find(tile.tile[opposite[dir] + "Edge"])

        if not my.kind == your.kind
          valid = false
        end

      end
    end
    
    if valid
      self.x = x
      self.y = y
      self.rotation = rotation
      self.status = "placed"
      self.save
    else
      return false
    end
    
  end

  def self.next(game_id)
    tiles = TileInstance.where(:game_id => game_id, :status => "current") 

    if not tiles.empty?
      return tiles.first
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

  def find_neighbours(x, y)
    n = {}

    north = TileInstance.where(:game_id => self.game, :x => (x - 1), :y => y)
    if not north.empty?
      n['north'] = north.first
    end

    south = TileInstance.where(:game_id => self.game, :x => (x + 1), :y => y)
    if not south.empty?
      n['south'] = south.first
    end

    west = TileInstance.where(:game_id => self.game, :x => x, :y => (y - 1))
    if not west.empty?
      n['west'] = west.first
    end

    east = TileInstance.where(:game_id => self.game, :x => x, :y => (y + 1))
    if not east.empty?
      n['east'] = east.first
    end

    return n
  end
  
end
