class AddMoveNumberToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :move_number, :integer, :default => 1
  end

  def self.down
    remove_column :games, :move_number
  end
end
