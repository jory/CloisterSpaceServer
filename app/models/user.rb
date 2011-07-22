class User < ActiveRecord::Base
  attr_accessible :email

  validates_presence_of :email
  validates_uniqueness_of :email

  def self.authenticate(email)
    user = find_by_email(email)
    if user
      user
    end
  end
end
