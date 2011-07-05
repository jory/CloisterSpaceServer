class Game < ActiveRecord::Base
  has_many :tileInstances

  def self.new(attributes = nil)
    game = super
    startingTile = nil
    
    Tile.all.each do |tile|
      for i in 1..tile.count
        tileInstance = TileInstance.create(:tile => tile, :game => game)
      end

      if tile.isStart?
        startingTile = tileInstance
      end
    end

    startingTile.place(72, 72, 0)
    game
  end

end
