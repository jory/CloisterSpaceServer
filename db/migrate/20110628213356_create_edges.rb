class CreateEdges < ActiveRecord::Migration
  def self.up
    create_table :edges do |t|
      t.string :kind
      t.integer :road
      t.integer :city
      t.integer :grassA
      t.integer :grassB

      t.timestamps
    end
  end

  def self.down
    drop_table :edges
  end
end
