class TileInstance < ActiveRecord::Base
  belongs_to :tile
  belongs_to :game

  def place(x, y, rotation)
    self.x = x
    self.y = y
    self.rotation = rotation
    self.status = "placed"
    self.save

    tiles = TileInstance.where(:game_id => self.game_id, :status => nil) 
    
    if not tiles.empty?
      tile = tiles[rand(tiles.size)]
      tile.status = "current"
      tile.save
    end
  end

end
