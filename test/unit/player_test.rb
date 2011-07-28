require 'test_helper'

class PlayerTest < ActiveSupport::TestCase

  def setup
    @user = users(:foobar)
    users = [@user.email]
    @game = Game.create(:creator => @user, :users => users)
  end

  test "invalid User" do
    assert !Player.create(:game => @game, :turn => 1).valid?
  end

  test "invalid Game" do
    assert !Player.create(:user => @user, :turn => 1).valid?
  end

  test "invalid turn" do
    assert !Player.create(:user => @user, :game => @game).valid?

    assert !Player.create(:user => @user, :game => @game, :turn => 0).valid?
    assert !Player.create(:user => @user, :game => @game, :turn => 6).valid?
    assert !Player.create(:user => @user, :game => @game, :turn => 'foo').valid?
  end

  test "valid Player" do
    assert Player.create(:user => @user, :game => @game, :turn => 1).valid?
  end
  
end
