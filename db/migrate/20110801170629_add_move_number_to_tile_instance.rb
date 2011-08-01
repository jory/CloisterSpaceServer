class AddMoveNumberToTileInstance < ActiveRecord::Migration
  def self.up
    add_column :tile_instances, :move_number, :integer
  end

  def self.down
    remove_column :tile_instances, :move_number
  end
end
