class EdgesController < ApplicationController
  
  def show
    @edge = Edge.find(params[:id])

    respond_to do |format|
      format.json { render :json => @edge }
    end
  end

end
