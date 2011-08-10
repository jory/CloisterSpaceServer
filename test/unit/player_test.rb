require 'test_helper'

class PlayerTest < ActiveSupport::TestCase

  def setup
    @game = games(:one)
    @user = users(:one)
  end

  test "valid Player" do
    player = Player.create(:user => @user, :game => @game,
                           :turn => 2, :colour => 'blue')
    assert player.valid?, player.errors.full_messages.to_s
  end

  test "invalid User" do
    assert Player.create(:game => @game, :turn => 1, :colour => 'blue').invalid?
  end

  test "invalid Game" do
    assert Player.create(:user => @user, :turn => 1, :colour => 'blue').invalid?
  end

  test "invalid turn" do
    assert Player.create(:user => @user, :game => @game, :colour => 'blue').invalid?

    assert Player.create(:user => @user, :game => @game, :colour => 'blue',
                         :turn => 0).invalid?

    assert Player.create(:user => @user, :game => @game, :colour => 'blue',
                         :turn => 6).invalid?

    assert Player.create(:user => @user, :game => @game, :colour => 'blue',
                         :turn => 'foo').invalid?
  end  
end
