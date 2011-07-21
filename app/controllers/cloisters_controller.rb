class CloistersController < ApplicationController

  respond_to :json

  def index
    c = Cloister.where(:game_id => params[:game_id])
    cloisters = c.collect do |cloister|
      [cloister, CloisterSection.where(:cloister_id => cloister)]
    end

    respond_with(cloisters)
  end

end
