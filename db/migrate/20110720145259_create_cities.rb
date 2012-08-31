class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.integer :size,     :default => 0
      t.integer :pennants, :default => 0
      t.boolean :finished, :default => false
      t.references :game

      t.timestamps
    end
  end

  def self.down
    drop_table :cities
  end
end
