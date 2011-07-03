class Game < ActiveRecord::Base
  has_many :tileInstances

  def self.new(attributes = nil)
    g = super

    Tile.all.each do |tile|
      for i in 1..tile.count
        t = TileInstance.create(:tile => tile, :game => g)
      end

      if tile.isStart?
        t.x = 72
        t.y = 72
        t.status = "placed"
        t.save
      end
    end

    g
  end

end
