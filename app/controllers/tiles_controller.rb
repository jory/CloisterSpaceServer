class TilesController < ApplicationController

  def index
    @tiles = Tile.all

    respond_to do |format|
      format.json { render :json => @tiles }
    end
  end
  
end
