class OpenEdge < ActiveRecord::Base

  validates :row, :numericality => { :greater_than => -1, :less_than => 145, :only_integer => true }
  validates :col, :numericality => { :greater_than => -1, :less_than => 145, :only_integer => true }
  validates :edge, :inclusion => { :in => %w( north south east west ) }

  validates :city, :presence => true
  
  belongs_to :city

end
