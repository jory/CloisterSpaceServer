require 'test_helper'

class GameTest < ActiveSupport::TestCase

  def setup
    @creator = users(:foobar)
    @users = [@creator.email]
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
    assert_equal(@users.size, @game.players.size)
    assert_equal(1, @game.players.size)
  end

  test "creator is populated" do
    assert !@game.creator.nil?
    assert_equal @game.creator, @creator
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

  test "destroying game destroys all created objects" do
    id = @game.id

    assert @game.destroy

    assert TileInstance.where(:game_id => id).empty?
    assert Road.where(:game_id => id).empty?
    assert City.where(:game_id => id).empty?
    assert Cloister.where(:game_id => id).empty?
    assert Farm.where(:game_id => id).empty?
  end

  test "have to include creator as player" do
    other = users(:baz)
    game = Game.create(:creator => @creator, :users => [other.email])
    assert !game.valid?
  end

  test "no empty players" do
    game = Game.create(:creator => @creator, :users => [@creator.email, "", "",
                                                        users(:baz).email])
    assert game.valid?

    assert_equal game.players.size, 2

    assert game.players.find_by_turn(1)
    assert game.players.find_by_turn(2)
    assert !game.players.find_by_turn(3)
    assert !game.players.find_by_turn(4)
  end

  test "users exist" do
    game = Game.create(:creator => @creator, :users => [@creator.email, "bonk!"])
    assert !game.valid?
  end
end
