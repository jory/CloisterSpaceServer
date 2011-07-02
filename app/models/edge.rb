class Edge < ActiveRecord::Base

  def self.find_or_create(kind, road, city, grassA, grassB)
    where(:kind => kind, :road => road, :city => city, :grassA => grassA, :grassB => grassB).first ||
      create(:kind => kind, :road => road, :city => city, :grassA => grassA, :grassB => grassB)
  end

end
