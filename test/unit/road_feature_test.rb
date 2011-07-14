require 'test_helper'

class RoadFeatureTest < ActiveSupport::TestCase

  def setup
    @game = Game.first
    @rf = RoadFeature.create(:game => @game)
  end

  test "needs game" do
    assert !RoadFeature.create().save
  end

  test "no nil arguments to add" do
    assert !@rf.add(nil, nil, nil, nil, nil)
    assert !@rf.add(nil, 0, :north, 0, false)    
    assert !@rf.add(0, nil, :north, 0, false)    
    assert !@rf.add(0, 0, nil, 0, false)    
    assert !@rf.add(0, 0, :north, nil, false)    
    assert !@rf.add(0, 0, :north, 0, nil)    
  end

  test "finished defaults to false" do
    assert !@rf.finished
  end

  test "created RoadSection is associated to us" do
    @rf.add(0, 0, :north, 0, true)
    assert !@rf.roadSections.empty?
  end
  
  test "numEnds increments, and sets finished" do
    assert @rf.numEnds == 0

    @rf.add(0, 0, :north, 0, true)
    assert @rf.numEnds == 1

    @rf.add(0, 0, :north, 0, true)
    assert @rf.numEnds == 2
    assert @rf.finished
  end

  test "can't add to something that's finished" do
    @rf.add(0, 0, :north, 0, true)
    @rf.add(0, 0, :north, 0, true)
    assert !@rf.add(0, 0, :north, 0, true)
  end

  test "can't merge with nil" do
    assert !@rf.merge(nil)
  end
  
  test "only merge within game" do
    other = RoadFeature.create(:game => Game.create())
    assert !@rf.merge(other)
  end
  
  test "merging to finish roads" do
    other = RoadFeature.create(:game => @game)

    @rf.add(0, 0, :north, 0, true)
    other.add(1, 1, :south, 1, true)

    @rf.merge(other)

    assert @rf.finished
  end

  test "can't merge with yourself" do
    assert !@rf.merge(@rf)
  end

  test "can't merge with a finished road" do
    other = RoadFeature.create(:game => @game)

    @rf.add(0, 0, :north, 0, true)
    @rf.add(0, 0, :north, 0, true)

    assert !@rf.merge(other)
  end

  test "length should increase properly" do
    assert @rf.length == 0

    @rf.add(0, 0, :north, 0, false)
    assert @rf.length == 1

    @rf.add(0, 0, :south, 0, false)
    assert @rf.length == 1

    @rf.add(0, 1, :north, 0, false)
    assert @rf.length == 2
  end

end
