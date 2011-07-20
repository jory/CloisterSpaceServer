class CreateFarmSections < ActiveRecord::Migration
  def self.up
    create_table :farm_sections do |t|
      t.integer :row
      t.integer :col
      t.string :edge
      t.integer :num
      t.references :farm

      t.timestamps
    end
  end

  def self.down
    drop_table :farm_sections
  end
end
