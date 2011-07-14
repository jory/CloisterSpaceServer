require 'test_helper'

class RoadFeatureTest < ActiveSupport::TestCase

  def setup
    @game = Game.first
  end

  test "needs game" do
    assert !RoadFeature.create().save
  end

  test "no nil arguments to add" do
    rf = RoadFeature.create(:game => @game)

    assert !rf.add(nil, nil, nil, nil, nil)
    assert !rf.add(nil, 0, :north, 0, false)    
    assert !rf.add(0, nil, :north, 0, false)    
    assert !rf.add(0, 0, nil, 0, false)    
    assert !rf.add(0, 0, :north, nil, false)    
    assert !rf.add(0, 0, :north, 0, nil)    
  end

  test "finished defaults to false" do
    rf = RoadFeature.create(:game => @game)
    assert !rf.finished
  end
end
