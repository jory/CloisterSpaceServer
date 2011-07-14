require 'test_helper'

class TileInstanceTest < ActiveSupport::TestCase

  def setup
    @game = Game.first

    @startingTile = tiles(:start)
    @otherTile = tiles(:second)
  end
  
  test "needs game" do
    assert !TileInstance.create(:tile => @startingTile).save
  end

  test "needs tile" do
    assert !TileInstance.create(:game => @game).save
  end

  test "not negative" do
    instance = TileInstance.create(:tile => @startingTile, :game => @game)
    assert !instance.place(-1, -1, 0)
  end

  test "no overlapping" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(0, 0, 0)

    q = TileInstance.create(:tile => @startingTile, :game => @game)
    assert !q.place(0, 0, 0)
  end

  test "no double placement" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(0, 0, 0)
    assert !p.place(1, 1, 1)
  end

  test "must set all" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    assert !p.place(nil, 0, 0)
    assert !p.place(0, nil, 0)
    assert !p.place(0, 0, nil)
  end

  test "must be adjacent" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)
    
    q = TileInstance.create(:tile => @otherTile, :game => @game)
    assert !q.place(0, 0, 0), "Placed a tile far away"
    assert q.place(72, 73, 0)
  end

  test "must match edges" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)

    q = TileInstance.create(:tile => @otherTile, :game => @game)
    assert !q.place(71, 72, 0)
    assert q.place(72, 73, 0)
  end

  test "must match rotated edges" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)
    
    q = TileInstance.create(:tile => @otherTile, :game => @game)
    assert q.place(73, 72, 2), "Couldn't place rotated next to non-rotated."

    r = TileInstance.create(:tile => @otherTile, :game => @game)
    assert r.place(73, 73, 2), "Couldn't place rotated next to rotated."

    s = TileInstance.create(:tile => @otherTile, :game => @game)
    assert s.place(73, 74, 0), "Couldn't place non-rotated next to rotated."

    t = TileInstance.create(:tile => @otherTile, :game => @game)
    assert t.place(72, 73, 0), "Couldn't place non-rotated next to both."
  end

  test "next returns current" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)

    q = TileInstance.create(:tile => @otherTile, :game => @game)
    q.status = "current"
    q.save

    r = TileInstance.create(:tile => tiles(:city4), :game => @game)
    
    assert q === TileInstance.next(@game)
  end
  
  test "next returns a tile" do
    p = TileInstance.create(:tile => @startingTile, :game => @game)
    p.place(72, 72, 0)

    q = TileInstance.create(:tile => @otherTile, :game => @game)

    r = TileInstance.create(:tile => tiles(:city4), :game => @game)
    
    assert TileInstance.next(@game)
  end

  ##########################################
  # Unlikely, but definitely needs to be handled at some point.
  ##########################################
  # test "shouldn't return unusable tiles" do
  #   p = TileInstance.create(:tile => @startingTile, :game => @game)
  #   p.place(72, 72, 0)

  #   q = TileInstance.create(:tile => @otherTile, :game => @game)
  #   q.place(71, 72, 2)
    
  #   r = TileInstance.create(:tile => tiles(:city4), :game => @game)
  #   assert !TileInstance.next(@game)
  # end
  ##########################################
    
end
