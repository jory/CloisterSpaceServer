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

  def create()
    super

    
    
  end
  
end
