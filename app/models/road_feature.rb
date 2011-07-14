class RoadFeature < ActiveRecord::Base
  validates :length, :numericality => true
  validates :numEnds, :numericality => true

  # TODO: Figure out validator for boolean, with default value.
  # validates :finished, :presence => true

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

    if self.roadSections.where(:x => x, :y => y).empty?
      self.length += 1
    end

    self.numEnds += 1 if hasEnd
    self.finished = true if numEnds == 2
    
    section = RoadSection.create(:road_feature => self)
    section.x = x
    section.y = y
    section.edge = edge.to_s
    section.num = num
    section.hasEnd = hasEnd
    section.save
  end

  def merge(other)
    if other.nil?
      return false
    end
    
    if other.game != self.game
      return false
    end

    if other == self
      return false
    end

    if self.finished
      return false
    end

    for section in other.roadSections
      add(section.x, section.y, section.edge, section.num, section.hasEnd)
    end

    return true
  end
end
