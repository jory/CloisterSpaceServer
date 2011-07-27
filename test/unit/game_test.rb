require 'test_helper'

class GameTest < ActiveSupport::TestCase

  def setup
    @creator = users(:foobar)
    @users = []
    @users << {:email => @creator.email}
    @game = Game.create(:creator => @creator, :users => @users)
  end

  test "needs something" do
    assert !Game.create().valid?
  end

  test "needs Creator" do
    assert !Game.create(:users => @users).valid?
  end

  test "needs Users" do
    assert !Game.create(:creator => @creator).valid?
  end
  
  test "valid Game" do
    assert Game.create(:creator => @creator, :users => @users).valid?
  end

  test "players is populated" do
    assert_equal(@users.count, @game.players.count)
    assert_equal(1, @game.players.count)
  end

  test "creator is populated" do
    assert !@game.creator.nil?
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
