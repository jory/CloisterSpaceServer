class EdgesController < ApplicationController

  respond_to :json
  
  def index
    @edges = Edge.all
    respond_with(@edges)
  end

  def show
    @edge = Edge.find(params[:id])
    respond_with(@edge)
  end

end
