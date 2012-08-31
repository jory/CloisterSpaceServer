class CloisterSection < ActiveRecord::Base

  validates :row, :numericality => { :greater_than => -1, :less_than => 145, :only_integer => true }
  validates :col, :numericality => { :greater_than => -1, :less_than => 145, :only_integer => true }

  validates :cloister, :presence => true
  
  belongs_to :cloister

end
