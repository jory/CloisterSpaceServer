class RenameXAndY < ActiveRecord::Migration
  def self.up
    rename_column(:cloisters, :x, :row)
    rename_column(:cloisters, :y, :col)

    rename_column(:road_sections, :x, :row)
    rename_column(:road_sections, :y, :col)

    rename_column(:tile_instances, :x, :row)
    rename_column(:tile_instances, :y, :col)
  end

  def self.down
    rename_column(:cloisters, :row, :x)
    rename_column(:cloisters, :col, :y)

    rename_column(:road_sections, :row, :x)
    rename_column(:road_sections, :col, :y)

    rename_column(:tile_instances, :row, :x)
    rename_column(:tile_instances, :col, :y)
  end
end
