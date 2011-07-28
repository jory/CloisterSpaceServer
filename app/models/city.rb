class City < ActiveRecord::Base

  validates :size,     :numericality => { :greater_than => -1, :only_integer => true }
  validates :pennants, :numericality => { :greater_than => -1, :only_integer => true }
  validates :finished, :inclusion => { :in => [true, false] }

  validates  :game, :presence => true
  belongs_to :game

  has_many :citySections, :dependent => :destroy
  has_many :openEdges,    :dependent => :destroy
  
  def add(row, col, edge, num, citysFields, hasPennant)
    if meets_add_preconditions? row, col, edge, num, citysFields, hasPennant

      if self.citySections.where(:row => row, :col => col).empty?
        self.size += 1
        if hasPennant
          self.pennants += 1
        end
      end

      check_open_edges(row, col, edge)
      
      CitySection.create(:city => self, :row => row, :col => col,
                         :edge => edge.to_s, :num => num,
                         :citysFields => citysFields, :hasPennant => hasPennant)

      self.save
    end
  end

  def merge(other)
    if meets_merge_preconditions? other
      other.citySections.each do |section|
        self.add(section.row, section.col, section.edge.to_sym, section.num,
                 section.citysFields, section.hasPennant)
      end

      other.delete
    end
  end
  
  def has(row, col, num)
    if self.citySections.where(:row => row, :col => col, :num => num).any?
      return true
    end
  end

  private

  def meets_add_preconditions?(row, col, edge, num, citysFields, hasPennant)
    if row.nil? or col.nil? or edge.nil? or num.nil? or citysFields.nil? or
        hasPennant.nil?
      return false
    end

    if self.citySections.where(:row => row, :col => col, :edge => edge,
                               :num => num, :citysFields => citysFields,
                               :hasPennant => hasPennant).any?
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

  def check_open_edges(row, col, edge)

    otherRow, otherCol = Tile.getAddress(row, col, edge)
    otherEdge = self.openEdges.where(:row => otherRow, :col => otherCol,
                                     :edge => Tile::Opposite[edge].to_s).first

    if otherEdge
      otherEdge.delete
    else
      OpenEdge.create(:city => self, :row => row, :col => col, :edge => edge.to_s)
    end

    if self.openEdges.count == 0
      self.finished = true
    else
      self.finished = false
    end
  end
  
end
