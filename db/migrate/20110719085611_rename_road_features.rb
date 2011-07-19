class RenameRoadFeatures < ActiveRecord::Migration
  def self.up
    rename_table(:road_features, :roads)
    rename_column(:road_sections, :road_feature_id, :road_id)
  end

  def self.down
    rename_table(:roads, :road_features)
    rename_column(:road_sections, :road_id, :road_feature_id)
  end
end
