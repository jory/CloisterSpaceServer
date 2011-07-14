class RoadSection < ActiveRecord::Base

  validates :x, :numericality => { :greater_than => -1, :less_than => 145,
                                   :allow_nil => true }
  validates :y, :numericality => { :greater_than => -1, :less_than => 145,
                                   :allow_nil => true }
  validates :edge, :inclusion => { :in => %w( north south east west ) }
  validates :num, :numericality => true

  # TODO: Figure out validator for boolean-ness
  validates :hasEnd, :presence => true

  validates :roadFeature, :presence => true
  
  belongs_to :roadFeature

end
