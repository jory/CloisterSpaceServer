require 'test_helper'

class RoadTest < ActiveSupport::TestCase

  def setup
    creator = users(:foobar)
    users = [:email => creator.email]
    @game = Game.create(:creator => creator, :users => users)
    @otherGame = Game.create(:creator => creator, :users => users)
    @road = Road.create(:game => @game)
  end

  test "needs game" do
    assert !Road.create().valid?
  end

  test "sensible defaults" do
    assert !@road.finished
    assert_equal @road.length, 0
    assert_equal @road.numEnds, 0
    assert @road.roadSections.empty?
  end

  test "no nil arguments to add" do
    assert !@road.add(nil, nil, nil, nil, nil)
    assert !@road.add(nil, 0, :north, 0, false)    
    assert !@road.add(0, nil, :north, 0, false)    
    assert !@road.add(0, 0, nil, 0, false)    
    assert !@road.add(0, 0, :north, nil, false)    
    assert !@road.add(0, 0, :north, 0, nil)    
  end

  test "can't add to something that's finished" do
    @road.add(0, 0, :north, 0, true)
    @road.add(0, 1, :north, 0, true)
    assert !@road.add(0, 2, :north, 0, true)
  end

  test "can't add the same thing twice" do
    @road.add(0, 0, :north, 0, false)
    assert !@road.add(0, 0, :north, 0, false)
  end

  test "created RoadSection is associated to us" do
    @road.add(0, 0, :north, 0, true)
    assert !@road.roadSections.empty?
  end
  
  test "numEnds increments, and sets finished" do
    @road.add(0, 0, :north, 0, true)
    assert_equal @road.numEnds, 1

    @road.add(0, 1, :north, 0, true)
    assert_equal @road.numEnds, 2
    assert @road.finished
  end

  test "length should increase properly" do
    @road.add(0, 0, :north, 0, false)
    assert_equal @road.length, 1

    @road.add(0, 0, :south, 0, false)
    assert_equal @road.length, 1

    @road.add(0, 1, :north, 0, false)
    assert_equal @road.length, 2
  end

  test "can't merge with nil" do
    assert !@road.merge(nil)
  end
  
  test "only merge within game" do
    other = Road.create(:game => @otherGame)
    assert !@road.merge(other)
  end
  
  test "can't merge with yourself" do
    assert !@road.merge(@road)
  end

  test "can't merge when already finished" do
    @road.add(0, 0, :north, 0, true)
    @road.add(0, 1, :north, 0, true)
    assert @road.finished
    
    other = Road.create(:game => @game)
    assert !@road.merge(other)
  end

  test "can't merge with a finished road" do
    other = Road.create(:game => @game)
    other.add(0, 0, :north, 0, true)
    other.add(0, 1, :north, 0, true)
    assert other.finished

    assert !@road.merge(other)
  end

  test "merging to finish roads" do
    other = Road.create(:game => @game)

    @road.add(0, 0, :north, 0, true)
    other.add(1, 1, :south, 1, true)

    @road.merge(other)

    assert @road.finished
  end

  test "adding order shouldn't matter" do
    @road.add(0, 0, :north, 0, true)

    assert_equal @road.length, 1

    other = Road.create(:game => @game)
    other.add(0, 1, :north, 0, true)
    other.add(0, 2, :north, 0, false)

    assert_equal other.length, 2

    @road.merge(other)

    assert_equal @road.length, 3
  end

  test "has shouldn't accept nil" do
    assert !@road.has(nil, nil, nil)
    assert !@road.has(nil, 0, 0)
    assert !@road.has(0, nil, 0)
    assert !@road.has(0, 0, nil)
  end

  test "has should return false if it doesn't haz" do
    assert !@road.has(0, 0, 0)
    @road.add(1, 1, :north, 1, true)
    assert !@road.has(0, 0, 0)
  end

  test "has should return true when it haz" do
    @road.add(0, 0, :north, 0, false)
    assert @road.has(0, 0, 0)
  end
    
end
