class CreateTileInstances < ActiveRecord::Migration
  def self.up
    create_table :tile_instances do |t|
      t.string :status
      t.integer :x
      t.integer :y
      t.integer :rotation
      t.references :tile
      t.references :game

      t.timestamps
    end
  end

  def self.down
    drop_table :tile_instances
  end
end
