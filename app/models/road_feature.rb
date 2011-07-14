class RoadFeature < ActiveRecord::Base
  validates :length, :numericality => true
  validates :numEnds, :numericality => true
  validates :finished, :presence => true

  validates :game, :presence => true

  has_many :roadSections
  belongs_to :game

  def add(x, y, edge, num, hasEnd)
    if x.nil? or y.nil? or edge.nil? or num.nil? or hasEnd.nil?
      return false
    end

    if self.finished
      return false
    end

    self.numEnds += 1 if hasEnd
    self.finished = true if numEnds == 2
    
    section = RoadSection.create(:roadFeature => self)
    section.x = x
    section.y = y
    section.edge = edge.to_s
    section.num = num
    section.hasEnd = hasEnd
    section.save

    return section
  end
end
