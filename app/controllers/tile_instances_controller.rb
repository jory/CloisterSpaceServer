class TileInstancesController < ApplicationController

  respond_to :json
  
  def index
    @tileInstances = TileInstance.where(:game_id => params[:game], :status => params[:status])
    respond_with(@tileInstances)
  end

  def update
    @tileInstance = TileInstance.find(params[:id])
    @tileInstance.place(params[:x], params[:y], params[:rotation])
    respond_with(@tileInstance)
  end

end
