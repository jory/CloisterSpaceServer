class AddRoadFeatureColumns < ActiveRecord::Migration
  def self.up
    add_column :road_features, :length, :integer, :default => 0
    add_column :road_features, :numEnds, :integer, :default => 0
  end

  def self.down
    remove_column :road_features, :length
    remove_column :road_features, :numEnds
  end
end
