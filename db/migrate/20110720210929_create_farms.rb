class CreateFarms < ActiveRecord::Migration
  def self.up
    create_table :farms do |t|
      t.integer :size,  :default => 0
      t.integer :score, :default => 0
      t.references :game

      t.timestamps
    end
  end

  def self.down
    drop_table :farms
  end
end
