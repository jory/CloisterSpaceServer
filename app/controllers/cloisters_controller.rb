class CloistersController < ApplicationController

  respond_to :json

  def index
    cloisters = Cloister.where(:game_id => params[:game]).collect do |cloister|
      [cloister, CloisterSection.where(:cloister_id => cloister)]
    end

    respond_with(cloisters)
  end

end
