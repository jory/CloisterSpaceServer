class RoadFeature < ActiveRecord::Base
  has_many :road_sections
  belongs_to :game
end
