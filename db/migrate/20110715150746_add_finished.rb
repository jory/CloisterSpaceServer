class AddFinished < ActiveRecord::Migration
  def self.up
    add_column :road_features, :finished, :boolean, :default => 0
  end

  def self.down
    remove_column :road_features, :finished
  end
end
