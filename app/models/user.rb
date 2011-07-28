class User < ActiveRecord::Base

  validates :email, :presence => true, :uniqueness => true

  has_many :games
  
  def self.authenticate(email)
    find_by_email(email)
  end
end
