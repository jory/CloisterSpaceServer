class User < ActiveRecord::Base

  validates :email, :presence => true, :uniqueness => true

  has_many :games
  
  def self.authenticate(email)
    user = find_by_email(email)
    if user
      user
    end
  end
end
