class RoadsController < ApplicationController

  respond_to :json

  def index
    roads = Road.where(:game_id => params[:game])

    sections = roads.collect do |road|
      RoadSection.where(:road_id => road)
    end
    
    respond_with(sections)
  end
end
