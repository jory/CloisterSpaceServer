class Game < ActiveRecord::Base

  attr_accessor :users

  validate :creator_in_users, :between_two_and_five_users

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
  end

  private
  
  def creator_in_users
    if users and creator
      found = false
      
      users.each do |user|
        if user[:email] == creator.email
          found = true
          break
        end
      end

      errors[:base] << "Creator has to be included among players." unless found
    end
  end

  def between_two_and_five_users
    if users
      errors[:base] << "Must have more than one player." unless users.size > 1
      errors[:base] << "Must have five or fewer players." unless users.size < 6
    end
  end

  def create_players
    users.each_with_index do |user, index|
      self.players.build(:user => User.find_by_email(user[:email]),
                         :colour => user[:colour],
                         :turn => (index + 1))
    end
  end

  def create_tile_instances
    Tile.all.each do |tile|
      for i in 1..tile.count
        tileInstance = self.tileInstances.create(:tile => tile)
      end
    end

    tile = Tile.where(:isStart => true, :image => 'city1rwe.png')
    tileInstance = self.tileInstances.where(:tile_id => tile).first

    tileInstance.move_number = 1
    tileInstance.place(72, 72, 0)
  end
end
