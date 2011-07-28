class AddColumnsToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :current_player, :integer, :default => 1
    add_column :games, :players_count, :integer
  end

  def self.down
    remove_column :games, :number_of_players
    remove_column :games, :players_count
  end
end
