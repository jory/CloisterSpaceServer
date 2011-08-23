class AddColumnsToTile < ActiveRecord::Migration
  def self.up
    add_column :tiles, :featurePolys, :string
    add_column :tiles, :meepleCoords, :string
  end

  def self.down
    remove_column :tiles, :meepleCoords
    remove_column :tiles, :featurePolys
  end
end
