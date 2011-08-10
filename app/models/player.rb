class Player < ActiveRecord::Base
  validate :unique_per_game, :on => :create

  validates :score, :numericality =>
    {:greater_than => -1, :only_integer => true}

  validates :unused_meeples, :numericality =>
    {:greater_than => -1, :less_than => 8, :only_integer => true}
  
  validates :turn, :numericality =>
    {:greater_than => 0, :less_than => 6, :only_integer => true}

  validates :colour, :inclusion =>
    {:in => %w(red blue green yellow black)}

  validates :user, :presence => true
  validates :game, :presence => true

  belongs_to :user
  belongs_to :game, :counter_cache => true

  private

  def unique_per_game
    if game and colour and user and turn
      if Player.where(:game_id => game, :colour => colour).any?
        p = Player.where(:game_id => game, :colour => colour)
        errors[:colour] << "can only appear once per game"
      end

      if Player.where(:game_id => game, :user_id => user).any?
        errors[:user] << "can only appear once per game"
      end

      if Player.where(:game_id => game, :turn => turn).any?
        errors[:turn] << "can only appear once per game"
      end
    end
  end
end
