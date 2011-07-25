class Player < ActiveRecord::Base
  validates :turn, :numericality =>
    {:greater_than => 0, :less_than => 6, :only_integer => true}

  validates :game, :presence => true
  validates :user, :presence => true

  belongs_to :game
  belongs_to :user
end
