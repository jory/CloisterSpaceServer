class Game < ActiveRecord::Base
  has_many :tileInstances
  has_many :roadFeatures

  def self.new(attributes = nil)
    game = super
    
    Tile.all.each do |tile|
      for i in 1..tile.count
        tileInstance = TileInstance.create(:tile => tile, :game => game)
      end

      if tile.isStart?
        tileInstance.place(72, 72, 0)
      end
    end

    return game
  end

end
