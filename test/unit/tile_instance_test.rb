require 'test_helper'

class TileInstanceTest < ActiveSupport::TestCase

  def setup
    @game = Game.first

    @tile = tiles(:start)
    @otherTile = tiles(:second)
  end
  
  test "needs game" do
    assert !TileInstance.create(:tile => @tile).save
  end

  test "needs tile" do
    assert !TileInstance.create(:game => @game).save
  end

  test "not negative" do
    instance = TileInstance.create(:tile => @tile, :game => @game)
    assert !instance.place(-1, -1, 0)
  end

  test "no overlapping" do
    p = TileInstance.create(:tile => @tile, :game => @game)
    p.place(0, 0, 0)

    q = TileInstance.create(:tile => @tile, :game => @game)
    assert !q.place(0, 0, 0)
  end

  test "no double placement" do
    p = TileInstance.create(:tile => @tile, :game => @game)
    p.place(0, 0, 0)
    assert !p.place(1, 1, 1)
  end

  test "must set all" do
    p = TileInstance.create(:tile => @tile, :game => @game)
    assert !p.place(nil, 0, 0)
    assert !p.place(0, nil, 0)
    assert !p.place(0, 0, nil)
  end

  test "must be adjacent" do
    p = TileInstance.create(:tile => @tile, :game => @game)
    p.place(72, 72, 0)
    
    q = TileInstance.create(:tile => @otherTile, :game => @game)
    assert !q.place(0, 0, 0), "Placed a tile far away"
    assert q.place(72, 73, 0)
  end

  test "must match edges" do
    p = TileInstance.create(:tile => @tile, :game => @game)
    p.place(72, 72, 0)

    q = TileInstance.create(:tile => @otherTile, :game => @game)
    assert !q.place(71, 72, 0)
    assert q.place(72, 73, 0)
  end

  test "must match rotated edges" do
    p = TileInstance.create(:tile => @tile, :game => @game)
    p.place(72, 72, 0)
    
    q = TileInstance.create(:tile => @otherTile, :game => @game)
    assert q.place(73, 72, 2)
  end
  
end
