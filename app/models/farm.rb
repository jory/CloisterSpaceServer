class Farm < ActiveRecord::Base
  validates :size, :numericality => true
  validates :score, :numericality => true

  validates :game, :presence => true

  belongs_to :game

  has_many :farmSections
end
