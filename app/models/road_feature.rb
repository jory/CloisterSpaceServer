class RoadFeature < ActiveRecord::Base
  validates :length, :numericality => true
  validates :numEnds, :numericality => true
  validates :finished, :presence => true

  validates :game, :presence => true

  has_many :roadSections
  belongs_to :game

  def add(row, col, edge, num, hasEnd)
    if row.nil? or col.nil? or edge.nil? or num.nil? or hasEnd.nil?
      return false
    end

    return true
  end
end
