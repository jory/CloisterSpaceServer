class CreateTiles < ActiveRecord::Migration
  def self.up
    create_table :tiles do |t|
      t.string :image
      t.integer :count
      t.boolean :hasTwoCities
      t.boolean :hasRoadEnd
      t.boolean :hasPennant
      t.boolean :isCloister
      t.boolean :isStart
      t.integer :rotation
      t.integer :citysFields
      t.integer :northEdge
      t.integer :southEdge
      t.integer :eastEdge
      t.integer :westEdge

      t.timestamps
    end
  end

  def self.down
    drop_table :tiles
  end
end
