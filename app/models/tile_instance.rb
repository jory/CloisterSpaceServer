class TileInstance < ActiveRecord::Base

  belongs_to :tile
  belongs_to :game

  validates :status, :inclusion => { :in => ['current', 'placed', 'discarded'],
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
