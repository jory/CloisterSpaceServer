class FarmSection < ActiveRecord::Base
  validates :row, :numericality => { :greater_than => -1, :less_than => 145, :only_integer => true }
  validates :col, :numericality => { :greater_than => -1, :less_than => 145, :only_integer => true }
  validates :edge, :inclusion => { :in => %w( north south east west ) }
  validates :num, :numericality => { :greater_than => -1, :only_integer => true }

  validates :farm, :presence => true
  
  belongs_to :farm

  def to_s
    "(#{row},#{col}) - #{edge} - #{num}"
  end
end
