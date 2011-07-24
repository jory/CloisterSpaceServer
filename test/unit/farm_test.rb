require 'test_helper'

class FarmTest < ActiveSupport::TestCase

  def setup
    @game = Game.create(:user => users(:foobar))
    @farm = Farm.create(:game => @game)
  end
  
  test "need game" do
    assert !Farm.create().valid?
  end

  test "sensible defaults" do
    assert_equal @farm.size, 0
    assert_equal @farm.score, 0
    assert @farm.farmSections.empty?
  end

  test "no nil arguments to add" do
    assert !@farm.add(nil, nil, nil, nil)
    assert !@farm.add(nil, 0, :north, 0)
    assert !@farm.add(0, nil, :north, 0)
    assert !@farm.add(0, 0, nil, 0)
    assert !@farm.add(0, 0, :north, nil)
  end

  test "single add increases size" do
    @farm.add(0, 0, :north, 0)
    assert_equal @farm.size, 1
  end

  test "don't add the same one twice" do
    @farm.add(0, 0, :north, 0)
    assert !@farm.add(0, 0, :north, 0)
  end

  test "haz when haz" do
    @farm.add(0, 0, :north, 0)
    assert @farm.has(0, 0, 0)
  end

  test "no haz when no haz" do
    assert !@farm.has(0, 0, 0)
  end

  test "don't merge with nil" do
    assert !@farm.merge(nil)
  end

  test "don't merge with self" do
    assert !@farm.merge(@farm)
  end

  test "don't merge between games" do
    f = Farm.create(:game => Game.create(:user => users(:foobar)))
    assert !@farm.merge(f)
  end
  
  test "merging two farms increases the size" do
    f = Farm.create(:game => @game)
    f.add(0, 0, :north, 0)

    @farm.merge(f)

    assert_equal @farm.size, 1
  end
  
end
