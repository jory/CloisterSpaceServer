class City < ActiveRecord::Base

  validates :size, :numericality => true
  validates :pennants, :numericality => true

  validates :game, :presence => true

  belongs_to :game

  has_many :citySections
  
  def add(row, col, edge, num, citysFields, hasPennant, merging = false)
    if meets_add_preconditions? row, col, edge, num, citysFields, hasPennant, merging
      if self.citySections.where(:row => row, :col => col).empty?
        self.size += 1
        if hasPennant
          self.pennants += 1
        end
      end

      # Need to somehow represent openEdges.

      CitySection.create(:city => self, :row => row, :col => col, :edge => edge.to_s,
                         :num => num, :citysFields => citysFields,
                         :hasPennant => hasPennant)

      self.save
    end
  end

  private

  def meets_add_preconditions?(row, col, edge, num, citysFields, hasPennant, merging)
    if row.nil? or col.nil? or edge.nil? or num.nil? or citysFields.nil? or
        hasPennant.nil?
      return false
    end

    if self.finished and not merging
      return false
    end

    if not self.citySections.where(:row => row, :col => col, :edge => edge,
                                   :num => num, :citysFields => citysFields,
                                   :hasPennant => hasPennant).empty?
      return false
    end

    return true
  end
  
end
