class TilesController < ApplicationController

  def index
    @tiles = Tile.all

    respond_to do |format|
      format.json { render :json => @tiles }
    end
  end
  
  def show
    @tile = Tile.find(params[:id])

    respond_to do |format|
      format.json { render :json => @tile }
    end
  end
  
end
