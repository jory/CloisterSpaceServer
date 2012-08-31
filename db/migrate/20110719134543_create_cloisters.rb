class CreateCloisters < ActiveRecord::Migration
  def self.up
    create_table :cloisters do |t|
      t.integer :x
      t.integer :y
      t.integer :size, :default => 1
      t.boolean :finished, :default => false
      t.references :game

      t.timestamps
    end
  end

  def self.down
    drop_table :cloisters
  end
end
