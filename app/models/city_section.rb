class CitySection < ActiveRecord::Base

  validates :row, :numericality => { :greater_than => -1, :less_than => 145}
  validates :col, :numericality => { :greater_than => -1, :less_than => 145}
  validates :edge, :inclusion => { :in => %w( north south east west ) }

  validates :city, :presence => true
  
  belongs_to :city
end
