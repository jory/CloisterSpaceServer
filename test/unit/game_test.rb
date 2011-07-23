require 'test_helper'

class GameTest < ActiveSupport::TestCase

  def setup
    @user = User.create(:email => "foo@bar.com")
    @game = Game.create(:user => @user)
  end

  test "game requires user" do
    assert !Game.create().save
  end

  test "valid game saves" do
    assert Game.create(:user => @user).save
  end

  test "an actually created game should place the starting tile automatically" do
    assert Road.where(:game_id => @game).any?
  end

  test "can access Roads using .roads" do
    assert @game.roads.any?
  end
end
