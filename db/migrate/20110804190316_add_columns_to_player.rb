class AddColumnsToPlayer < ActiveRecord::Migration
  def self.up
    add_column :players, :score, :integer, :default => 0
    add_column :players, :colour, :string
    add_column :players, :unused_meeples, :integer, :default => 7
  end

  def self.down
    remove_column :players, :unused_meeples
    remove_column :players, :colour
    remove_column :players, :score
  end
end
