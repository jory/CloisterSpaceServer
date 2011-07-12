require 'test_helper'

class TileInstanceTest < ActiveSupport::TestCase

  def setup
    @game = Game.first
    @tile = Tile.first
  end
  
  test "needs game" do
    assert !TileInstance.create(:tile => @tile).save
  end

  test "needs tile" do
    assert !TileInstance.create(:game => @game).save
  end

  test "not negative" do
    instance = TileInstance.create(:tile => @tile, :game => @game)
    instance.x = -1
    instance.y = -1
    instance.rotation = 0
    assert !instance.save
  end

end
