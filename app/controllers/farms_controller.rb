class FarmsController < ApplicationController

  respond_to :json

  def index
    farms = Farm.where(:game_id => params[:game])

    sections = farms.collect do |farm|
      FarmSection.where(:farm_id => farm)
    end

    respond_with(sections)
  end
  
end
