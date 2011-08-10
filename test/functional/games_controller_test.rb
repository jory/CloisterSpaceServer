require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  setup do
    @creator = users(:foobar)
    @other = users(:baz)
    @users = [{:email => @creator.email, :colour => 'blue'},
              {:email => @other.email, :colour => 'red'}]
    @game = games(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:games)
  end

  test "should get new" do
    get :new, nil, {:user_id => @creator.id}
    assert_response :success
    assert_not_nil assigns(:game)
  end

  test "should create game" do
    assert_difference('Game.count') do
      attrs = @game.attributes
      attrs[:users] = @users

      post :create, {:game => attrs}, {:user_id => @creator.id}
    end

    assert_redirected_to game_path(assigns(:game))
  end

  test "should show game" do
    get :show, {:id => @game.to_param}, {:user_id => @creator.id}
    assert_response :success
    assert_not_nil assigns(:game)
  end

  test "should not show game" do
    get :show, {:id => @game.to_param}, {:user_id => @other.id}
    assert_redirected_to games_path
    assert_equal "Naughty!", flash[:error]
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete :destroy, {:id => @game.to_param}, {:user_id => @creator.id}
    end

    assert_redirected_to games_path
  end
end
