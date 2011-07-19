class CloisterSection < ActiveRecord::Base

  validates :row, :numericality => { :greater_than => -1, :less_than => 145}
  validates :col, :numericality => { :greater_than => -1, :less_than => 145}

  validates :cloister, :presence => true
  
  belongs_to :cloister
end
