class Tile < ActiveRecord::Base
  has_many :tileInstances

  validates :image, :presence => true
  validates :count, :presence => true
  validates :hasTwoCities, :presence => true
  validates :hasRoadEnd, :presence => true
  validates :hasPennant, :presence => true
  validates :isCloister, :presence => true
  validates :isStart, :presence => true
  validates :citysFields, :presence => true
  validates :northEdge, :presence => true
  validates :southEdge, :presence => true
  validates :eastEdge, :presence => true
  validates :westEdge, :presence => true

end
