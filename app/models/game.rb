class Game < ActiveRecord::Base

  attr_accessor :users

  before_validation :sanitize_users

  validate :creator_in_users, :users_exist

  validates  :creator, :presence => true
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"

  validates :users, :presence => true, :on => :create

  validates :current_player, :inclusion => {:in => 1..5}

  validates :move_number, :numericality =>
    {:only_integer => true, :greater_than => 0}

  before_create  :create_players
  after_create   :create_tile_instances

  has_many :players,       :dependent => :destroy
  has_many :tileInstances, :dependent => :destroy
  has_many :roads,         :dependent => :destroy
  has_many :cloisters,     :dependent => :destroy
  has_many :cities,        :dependent => :destroy
  has_many :farms,         :dependent => :destroy

  def next
    current = self.tileInstances.where(:status => "current") 

    if current.any?
      return current.first
    end

    tiles = self.tileInstances.where(:status => nil)
    
    if tiles.any?
      self.move_number += 1

      if self.current_player == self.players.size
        self.current_player = 1
      else
        self.current_player += 1
      end
      
      self.save

      tile = tiles[rand(tiles.size)]
      tile.status = "current"
      tile.move_number = self.move_number

      tile.save

      return tile
    end
  end

  private
  
  def sanitize_users
    if users
      users.delete("")
    end
  end

  def creator_in_users
    if users and creator
      errors[:base] << "Creator has to be included among players." unless
        users.index(creator.email)
    end
  end

  def users_exist
    if users
      users.each do |email|
        if User.find_by_email(email).nil?
          errors[:base] << "All players must already been signed up."
          break
        end
      end
    end
  end

  def create_players
    users.each_with_index do |email, index|
      self.players.build(:user => User.find_by_email(email),
                         :turn => (index + 1))
    end
  end

  def create_tile_instances
    Tile.all.each do |tile|
      for i in 1..tile.count
        tileInstance = self.tileInstances.create(:tile => tile)
      end

      if tile.isStart? and tile.image == 'city1rwe.png'
        tileInstance.move_number = 1
        tileInstance.place(72, 72, 0)
      end
    end
  end
end
