require 'test_helper'

class GameTest < ActiveSupport::TestCase

  test "an actually created game should place the starting tile automatically" do
    game = Game.create()
    assert !RoadFeature.where(:game_id => game).empty?
  end

  test "can access RoadFeatures using .roadFeatures" do
    game = Game.create()
    assert !game.roadFeatures.empty?
  end
end
