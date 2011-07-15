class RenameEdges < ActiveRecord::Migration
  def self.up
    rename_column :tiles, :northEdge, :north
    rename_column :tiles, :southEdge, :south
    rename_column :tiles, :eastEdge, :east
    rename_column :tiles, :westEdge, :west
  end

  def self.down
    rename_column :tiles, :north, :northEdge
    rename_column :tiles, :south, :southEdge
    rename_column :tiles, :east, :eastEdge
    rename_column :tiles, :west, :westEdge
  end
end
