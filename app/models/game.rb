class Game < ActiveRecord::Base

  after_create :create_tile_instances

  validates  :creator, :presence => true
  belongs_to :creator, :class_name => "User"

  has_many :tileInstances, :dependent => :destroy
  has_many :roads,         :dependent => :destroy
  has_many :cloisters,     :dependent => :destroy
  has_many :cities,        :dependent => :destroy
  has_many :farms,         :dependent => :destroy

  def next
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

  private

  def create_tile_instances
    Tile.all.each do |tile|
      for i in 1..tile.count
        tileInstance = self.tileInstances.create(:tile => tile)
      end

      if tile.isStart? and tile.image == 'city1rwe.png'
        tileInstance.place(72, 72, 0)
      end
    end
  end
end
