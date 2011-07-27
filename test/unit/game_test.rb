require 'test_helper'

class GameTest < ActiveSupport::TestCase

  def setup
    @user = users(:foobar)
    @game = Game.create(:creator => @user)
  end

  test "need User" do
    assert !Game.create().valid?
  end

  test "valid Game" do
    assert Game.create(:creator => @user).valid?
  end

  test "starting tile is placed automatically" do
    assert @game.tileInstances.where(:status => 'placed').any?
    assert @game.roads.any?
    assert @game.cities.any?
    assert @game.farms.any?
    assert @game.cloisters.empty?
  end

  test "next returns current" do
    assert_not_nil @game.next()
    assert_equal @game.tileInstances.where(:status => "current").first, @game.next()
  end

end
