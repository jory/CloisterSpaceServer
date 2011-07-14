class RoadSection < ActiveRecord::Base

  validates :x, :numericality => { :greater_than => -1, :less_than => 145}
  validates :y, :numericality => { :greater_than => -1, :less_than => 145}
  validates :edge, :inclusion => { :in => %w( north south east west ) }
  validates :num, :numericality => true

  # TODO: Figure out validator for boolean-ness
  # validates :hasEnd, :presence => true

  validates :road_feature, :presence => true
  
  belongs_to :road_feature

end
