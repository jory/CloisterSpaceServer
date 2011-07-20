class Farm < ActiveRecord::Base
  validates :size, :numericality => true
  validates :score, :numericality => true

  validates :game, :presence => true

  belongs_to :game

  has_many :farmSections

  def add(row, col, edge, num)
    if meets_add_preconditions? row, col, edge, num

      if self.farmSections.where(:row => row, :col => col).empty?
        self.size += 1
      end

      self.farmSections.create(:row => row, :col => col, :edge => edge.to_s,
                               :num => num)

      self.save
    end
  end

  def merge(other)
    if meets_merge_preconditions? other
      for section in other.farmSections
        add(section.row, section.col, section.edge, section.num)
      end

      other.delete
    end
  end
  
  def has(row, col, num)
    if not self.farmSections.where(:row => row, :col => col, :num => num).empty?
      return true
    end
  end
  
  private

  def meets_add_preconditions?(row, col, edge, num)
    if row.nil? or col.nil? or edge.nil? or num.nil?
      return false
    end

    if not self.farmSections.where(:row => row, :col => col, :edge => edge,
                                   :num => num).empty?
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

    return true
  end
end
