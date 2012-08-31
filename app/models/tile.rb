class Tile < ActiveRecord::Base
  has_many :tileInstances

  # validates :image, :presence => true
  # validates :count, :presence => true
  # validates :hasTwoCities, :presence => true
  # validates :hasRoadEnd, :presence => true
  # validates :hasPennant, :presence => true
  # validates :isCloister, :presence => true
  # validates :isStart, :presence => true
  # validates :citysFields, :presence => true
  # validates :northEdge, :presence => true
  # validates :southEdge, :presence => true
  # validates :eastEdge, :presence => true
  # validates :westEdge, :presence => true

  Opposite = {}
  Opposite[:north] = :south
  Opposite[:south] = :north
  Opposite[:east]  = :west
  Opposite[:west]  = :east

  Directions = Opposite.keys
  
  def self.getAddress(row, col, dir)
    if dir == :north    then return row - 1, col
    elsif dir == :south then return row + 1, col
    elsif dir == :east  then return row, col + 1
    elsif dir == :west  then return row, col - 1
    else raise "Unsupported direction: #{dir}"
    end
  end
  
end
