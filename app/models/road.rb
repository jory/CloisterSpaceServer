class Road < ActiveRecord::Base
  # TODO: Figure out how to make these read only to the outside world.
  validates :length, :numericality => true
  validates :numEnds, :numericality => true

  # TODO: Figure out validator for boolean, with default value.
  # validates :finished, :presence => true

  validates :game, :presence => true

  belongs_to :game

  has_many :roadSections

  def add(row, col, edge, num, hasEnd, merging=false)
    if not meets_add_preconditions? row, col, edge, num, hasEnd, merging
      return false
    end

    if self.roadSections.where(:row => row, :col => col).empty?
      self.length += 1
    end

    self.numEnds += 1 if hasEnd
    self.finished = true if numEnds == 2
    
    RoadSection.create(:road => self, :row => row, :col => col, :edge => edge.to_s,
                       :num => num, :hasEnd => hasEnd)

    self.save
  end

  def merge(other)
    if not meets_merge_preconditions? other
      return false
    end
    
    for section in other.roadSections
      add(section.row, section.col, section.edge, section.num, section.hasEnd, true)
    end

    return true
  end

  def has(row, col, num)
    if not self.roadSections.where(:row => row, :col => col, :num => num).empty?
      return true
    end
  end
  
  private

  def meets_add_preconditions?(row, col, edge, num, hasEnd, merging)
    if row.nil? or col.nil? or edge.nil? or num.nil? or hasEnd.nil?
      return false
    end

    if self.finished and not merging
      return false
    end

    if not self.roadSections.where(:row => row, :col => col, :edge => edge, :num => num,
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
