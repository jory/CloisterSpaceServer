# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110714174004) do

  create_table "edges", :force => true do |t|
    t.string   "kind"
    t.integer  "road"
    t.integer  "city"
    t.integer  "grassA"
    t.integer  "grassB"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "road_features", :force => true do |t|
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length",     :default => 0
    t.integer  "numEnds",    :default => 0
  end

  create_table "road_sections", :force => true do |t|
    t.integer  "x"
    t.integer  "y"
    t.string   "edge"
    t.integer  "num"
    t.boolean  "hasEnd"
    t.integer  "road_feature_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tile_instances", :force => true do |t|
    t.string   "status"
    t.integer  "x"
    t.integer  "y"
    t.integer  "rotation"
    t.integer  "tile_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tiles", :force => true do |t|
    t.string   "image"
    t.integer  "count"
    t.boolean  "hasTwoCities"
    t.boolean  "hasRoadEnd"
    t.boolean  "hasPennant"
    t.boolean  "isCloister"
    t.boolean  "isStart"
    t.integer  "citysFields"
    t.integer  "northEdge"
    t.integer  "southEdge"
    t.integer  "eastEdge"
    t.integer  "westEdge"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
