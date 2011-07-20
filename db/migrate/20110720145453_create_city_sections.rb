class CreateCitySections < ActiveRecord::Migration
  def self.up
    create_table :city_sections do |t|
      t.integer :row
      t.integer :col
      t.string :edge
      t.integer :num
      t.integer :citysFields
      t.boolean :hasPennant
      t.references :city

      t.timestamps
    end
  end

  def self.down
    drop_table :city_sections
  end
end
