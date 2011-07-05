class TileInstancesController < ApplicationController

  respond_to :json
  
  def index
    @TileInstances = TileInstance.where(:game_id => params[:game], :status => params[:status])
    respond_with(@TileInstances)
  end

end
