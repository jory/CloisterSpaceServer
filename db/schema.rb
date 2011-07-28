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

ActiveRecord::Schema.define(:version => 20110728141347) do

  create_table "cities", :force => true do |t|
    t.integer  "size",       :default => 0
    t.integer  "pennants",   :default => 0
    t.boolean  "finished",   :default => false
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "city_sections", :force => true do |t|
    t.integer  "row"
    t.integer  "col"
    t.string   "edge"
    t.integer  "num"
    t.integer  "citysFields"
    t.boolean  "hasPennant"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cloister_sections", :force => true do |t|
    t.integer  "row"
    t.integer  "col"
    t.integer  "cloister_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cloisters", :force => true do |t|
    t.integer  "row"
    t.integer  "col"
    t.integer  "size",       :default => 1
    t.boolean  "finished",   :default => false
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "edges", :force => true do |t|
    t.string   "kind"
    t.integer  "road"
    t.integer  "city"
    t.integer  "grassA"
    t.integer  "grassB"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "farm_sections", :force => true do |t|
    t.integer  "row"
    t.integer  "col"
    t.string   "edge"
    t.integer  "num"
    t.integer  "farm_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "farms", :force => true do |t|
    t.integer  "size",       :default => 0
    t.integer  "score",      :default => 0
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "current_player", :default => 1
    t.integer  "players_count"
  end

  create_table "open_edges", :force => true do |t|
    t.integer  "row"
    t.integer  "col"
    t.string   "edge"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.integer  "turn"
    t.integer  "game_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "road_sections", :force => true do |t|
    t.integer  "row"
    t.integer  "col"
    t.string   "edge"
    t.integer  "num"
    t.boolean  "hasEnd"
    t.integer  "road_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roads", :force => true do |t|
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length",     :default => 0
    t.integer  "numEnds",    :default => 0
    t.boolean  "finished",   :default => false
  end

  create_table "tile_instances", :force => true do |t|
    t.string   "status"
    t.integer  "row"
    t.integer  "col"
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
    t.integer  "north"
    t.integer  "south"
    t.integer  "east"
    t.integer  "west"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
