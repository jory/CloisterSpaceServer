class TileInstancesController < ApplicationController

  respond_to :json
  
  def index
    @tileInstances = TileInstance.where(:game_id => params[:game_id],
                                        :status => params[:status])
    respond_with(@tileInstances)
  end

  def update
    @tileInstance = TileInstance.find(params[:id])

    game = @tileInstance.game
    current = Player.find_by_game_id_and_turn(game.id, game.current_player)

    if current.user.id == session[:user_id]
      @tileInstance.place(params[:x].to_i, params[:y].to_i,
                          params[:rotation].to_i)
    end
    
    respond_with(@tileInstance)
  end

end
