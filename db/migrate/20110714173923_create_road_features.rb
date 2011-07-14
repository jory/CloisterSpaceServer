class CreateRoadFeatures < ActiveRecord::Migration
  def self.up
    create_table :road_features do |t|
      t.references :game

      t.timestamps
    end
  end

  def self.down
    drop_table :road_features
  end
end
