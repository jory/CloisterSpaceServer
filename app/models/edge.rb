class Edge < ActiveRecord::Base

  validates :kind, :presence => true
  validates :road, :presence => true
  validates :city, :presence => true
  validates :grassA, :presence => true
  validates :grassB, :presence => true

  def self.find_or_create(kind, road, city, grassA, grassB)
    where(:kind => kind, :road => road, :city => city, :grassA => grassA, :grassB => grassB).first ||
      create(:kind => kind, :road => road, :city => city, :grassA => grassA, :grassB => grassB)
  end

end
