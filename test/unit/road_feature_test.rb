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

  test "numEnds increments, and sets finished" do
    assert @rf.numEnds == 0

    @rf.add(0, 0, :north, 0, true)
    assert @rf.numEnds == 1

    @rf.add(0, 0, :north, 0, true)
    assert @rf.numEnds == 2
    assert @rf.finished == true
  end

  test "can't add to something that's finished" do
    @rf.add(0, 0, :north, 0, true)
    @rf.add(0, 0, :north, 0, true)
    assert !@rf.add(0, 0, :north, 0, true)
  end
end
