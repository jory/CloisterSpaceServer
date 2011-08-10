require 'test_helper'

class GameTest < ActiveSupport::TestCase

  def setup
    @creator = users(:foobar)

    @players = [{:email => @creator.email, :colour => 'blue'},
                {:email => users(:baz).email, :colour => 'red'}]

    @game = Game.create(:creator => @creator, :users => @players)
  end

  test "valid Game" do
    assert @game.valid?, @game.errors.full_messages.to_s
  end

  test "multiple games for the same players" do
    assert Game.create(:creator => @creator, :users => @players).valid?
  end

  test "needs something" do
    assert Game.create().invalid?
  end

  test "needs Creator" do
    assert Game.create(:users => @players).invalid?
  end

  test "needs Users" do
    assert Game.create(:creator => @creator).invalid?
  end

  test "have to include creator as player" do
    @players = [{:email => users(:one).email, :colour => 'blue'},
                {:email => users(:two).email, :colour => 'red'}]

    assert Game.create(:creator => @creator, :users => @players).invalid?
  end

  test "no empty players" do
    @players << {:email => '', :colour => 'green'}

    assert Game.create(:creator => @creator, :users => @players).invalid?
  end

  test "no empty colours" do
    @players << {:email => users(:one).email, :colour => ''}

    assert Game.create(:creator => @creator, :users => @players).invalid?
  end

  test "no duplicate colours" do
    @players << {:email => users(:one).email, :colour => 'blue'}

    assert Game.create(:creator => @creator, :users => @players).invalid?
  end

  test "no duplicate players" do
    @players << {:email => @creator.email, :colour => 'green'}

    assert Game.create(:creator => @creator, :users => @players).invalid?
  end

  test "only valid colours" do
    @players << {:email => users(:one).email, :colour => 'purple'}

    assert Game.create(:creator => @creator, :users => @players).invalid?
  end
  
  test "users exist" do
    @players << {:email => 'bonk!', :colour => 'green'}

    assert Game.create(:creator => @creator, :users => @players).invalid?
  end

  test "five players max, two players min" do
    @players << {:email => users(:one).email, :colour => 'green'}
    @players << {:email => users(:two).email, :colour => 'yellow'}
    @players << {:email => users(:three).email, :colour => 'black'}
    @players << {:email => users(:four).email, :colour => 'purple'}

    assert Game.create(:creator => @creator, :users => @players[0, 1]).invalid?

    g = Game.create(:creator => @creator, :users => @players[0, 2])
    assert g.valid?, g.errors.full_messages.to_s

    assert Game.create(:creator => @creator, :users => @players[0, 3]).valid?
    assert Game.create(:creator => @creator, :users => @players[0, 4]).valid?
    assert Game.create(:creator => @creator, :users => @players[0, 5]).valid?
    assert Game.create(:creator => @creator, :users => @players[0, 6]).invalid?
  end

  test "players is populated" do
    assert_equal(@players.size, @game.players.size)
    assert_equal(2, @game.players.size)
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
end
