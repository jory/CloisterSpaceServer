class RoadFeaturesController < ApplicationController

  respond_to :json

  def index
    roadFeatures = RoadFeature.where(:game_id => params[:game])

    sections = roadFeatures.collect do |roadFeature|
      RoadSection.where(:road_feature_id => roadFeature)
    end
    
    respond_with(sections)
  end
end
