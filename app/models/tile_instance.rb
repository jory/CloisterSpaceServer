class TileInstance < ActiveRecord::Base
  belongs_to :tile
  belongs_to :game
end
