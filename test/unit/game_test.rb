require 'test_helper'

class GameTest < ActiveSupport::TestCase

  test "an actually created game should place the starting tile automatically" do
    game = Game.create()
    assert !Road.where(:game_id => game).empty?
  end

  test "can access Roads using .roads" do
    game = Game.create()
    assert !game.roads.empty?
  end
end
