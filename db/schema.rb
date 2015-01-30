# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150122061936) do

  create_table "game_boards", force: :cascade do |t|
    t.integer "size"
    t.boolean "ready",           default: false
    t.string  "ships_positions"
    t.integer "game_id"
    t.integer "player_id"
  end

  create_table "games", force: :cascade do |t|
    t.string  "moves_p1"
    t.string  "moves_p2"
    t.integer "winner_id"
    t.integer "player1_id"
    t.integer "player2_id"
    t.integer "turn_player_id"
    t.integer "game_board1_id"
    t.integer "game_board2_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
  end

end
