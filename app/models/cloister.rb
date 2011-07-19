class Cloister < ActiveRecord::Base

  validates :row, :numericality => { :greater_than => -1, :less_than => 145},
                  :presence => true
  validates :col, :numericality => { :greater_than => -1, :less_than => 145},
                  :presence => true

  validates :size, :numericality => true

  # TODO: Figure out validator for boolean, with default value.
  # validates :finished, :presence => true

  validates :game, :presence => true

  belongs_to :game


  def add(row, col)
    if neighbours(row, col)
      self.size += 1
      self.finished = true if self.size == 9
    end
  end

  def neighbours(row, col)
    if (self.row - 1) <= row and row <= (self.row + 1) and
        (self.col - 1) <= col and col <= (self.col + 1)
      return true
    end
  end
end
