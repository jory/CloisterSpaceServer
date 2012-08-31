class CreateCloisterSections < ActiveRecord::Migration
  def self.up
    create_table :cloister_sections do |t|
      t.integer :row
      t.integer :col
      t.references :cloister

      t.timestamps
    end
  end

  def self.down
    drop_table :cloister_sections
  end
end
