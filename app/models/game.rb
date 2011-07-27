class Game < ActiveRecord::Base

  validates :creator, :presence => true

  belongs_to :creator, :class_name => "User"

  has_many :tileInstances
  has_many :roads
  has_many :cloisters
  has_many :cities
  has_many :farms

  def self.new(attributes = nil)
    game = super(attributes)
    
    if game.save
      Tile.all.each do |tile|
        for i in 1..tile.count
          tileInstance = game.tileInstances.create(:tile => tile)
        end

        if tile.isStart? and tile.image == 'city1rwe.png'
          tileInstance.place(72, 72, 0)
        end
      end
    end

    return game
  end

  def next()
    current = self.tileInstances.where(:status => "current") 

    if current.any?
      return current.first
    end

    tiles = self.tileInstances.where(:status => nil)
    
    if tiles.any?
      tile = tiles[rand(tiles.size)]
      tile.status = "current"
      tile.save
      return tile
    end
  end

end
