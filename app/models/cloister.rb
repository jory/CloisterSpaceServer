class Cloister < ActiveRecord::Base

  validates :row,  :numericality => { :greater_than => -1, :less_than => 145,
                                     :only_integer => true }
  validates :col,  :numericality => { :greater_than => -1, :less_than => 145,
                                     :only_integer => true }

  validates :size, :numericality => { :greater_than => -1, :less_than => 10,
                                      :only_integer => true }

  validates :finished, :inclusion => { :in => [true, false] }

  validates  :game, :presence => true
  belongs_to :game

  has_many :cloisterSections, :dependent => :destroy

  def add(row, col)
    if neighbours(row, col)
      self.size += 1
      self.finished = true if self.size == 9

      self.cloisterSections.create(:row => row, :col => col)
      
      self.save
    end
  end

  def neighbours(row, col)
    if (self.row - 1) <= row and row <= (self.row + 1)
      if (self.col - 1) <= col and col <= (self.col + 1)
        if not (row == self.row and col == self.col)
          return true
        end
      end
    end
  end
  
end
