class CitiesController < ApplicationController

  respond_to :json

  def index
    cities = City.where(:game_id => params[:game_id])

    sections = cities.collect do |city|
      CitySection.where(:city_id => city)
    end

    respond_with(sections)
  end
end
