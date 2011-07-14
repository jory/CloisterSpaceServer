class CreateRoadSections < ActiveRecord::Migration
  def self.up
    create_table :road_sections do |t|
      t.integer    :x
      t.integer    :y
      t.string     :edge
      t.integer    :num
      t.boolean    :hasEnd
      t.references :road_feature

      t.timestamps
    end
  end

  def self.down
    drop_table :road_sections
  end
end
