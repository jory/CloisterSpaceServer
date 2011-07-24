class Road < ActiveRecord::Base

  validates :length, :numericality => { :greater_than => -1,
                                        :only_integer => true }

  validates :numEnds, :numericality => { :greater_than => -1,
                                         :only_integer => true }

  validates :finished, :inclusion => { :in => [true, false] }

  validates :game, :presence => true

  belongs_to :game

  has_many :roadSections

  def add(row, col, edge, num, hasEnd, merging = false)
    if meets_add_preconditions? row, col, edge, num, hasEnd, merging

      if self.roadSections.where(:row => row, :col => col).empty?
        self.length += 1
      end

      self.numEnds += 1 if hasEnd
      self.finished = true if numEnds == 2
      
      self.roadSections.create(:row => row, :col => col, :edge => edge.to_s,
                               :num => num, :hasEnd => hasEnd)

      self.save
    end
  end

  def merge(other)
    if meets_merge_preconditions? other

      for section in other.roadSections
        add(section.row, section.col, section.edge, section.num, section.hasEnd, true)
      end

      other.delete
    end
  end

  def has(row, col, num)
    if self.roadSections.where(:row => row, :col => col, :num => num).any?
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

    if self.roadSections.where(:row => row, :col => col, :edge => edge,
                               :num => num, :hasEnd => hasEnd).any?
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
