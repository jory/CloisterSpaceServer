class CreateOpenEdges < ActiveRecord::Migration
  def self.up
    create_table :open_edges do |t|
      t.integer :row
      t.integer :col
      t.string :edge
      t.references :city

      t.timestamps
    end
  end

  def self.down
    drop_table :open_edges
  end
end
