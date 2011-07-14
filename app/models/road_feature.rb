class RoadFeature < ActiveRecord::Base
  validates :length, :numericality => true
  validates :numEnds, :numericality => true

  # TODO: Figure out validator for boolean, with default value.
  # validates :finished, :presence => true

  validates :game, :presence => true

  belongs_to :game

  has_many :roadSections

  def add(x, y, edge, num, hasEnd, merging=false)
    if not meets_add_preconditions? x, y, edge, num, hasEnd, merging
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
    if not meets_merge_preconditions? other
      return false
    end
    
    for section in other.roadSections
      add(section.x, section.y, section.edge, section.num, section.hasEnd, true)
    end

    return true
  end

  private

  def meets_add_preconditions?(x, y, edge, num, hasEnd, merging)
    if x.nil? or y.nil? or edge.nil? or num.nil? or hasEnd.nil?
      return false
    end

    if self.finished and not merging
      return false
    end

    if not self.roadSections.where(:x => x, :y => y,
                                   :edge => edge, :num => num,
                                   :hasEnd => hasEnd).empty?
      return false
    end

    return true
  end

  def meets_merge_preconditions?(other)
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

    if other.finished
      return false
    end

    return true
  end
end
