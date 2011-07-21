class EdgesController < ApplicationController

  respond_to :json
  
  def index
    @edges = Edge.all
    respond_with(@edges)
  end

end
