# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_04_21_161414) do
  create_table "bed_time_histories", force: :cascade do |t|
    t.datetime "bed_time"
    t.datetime "wake_up_time"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sleep_duration", default: 0, null: false
    t.index ["sleep_duration"], name: "index_bed_time_histories_on_sleep_duration"
    t.index ["user_id"], name: "index_bed_time_histories_on_user_id"
  end

  create_table "user_followers", force: :cascade do |t|
    t.integer "follower_id", null: false
    t.integer "following_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_id"], name: "index_user_followers_on_follower_id"
    t.index ["following_id", "follower_id"], name: "index_user_followers_on_following_id_and_follower_id", unique: true
    t.index ["following_id"], name: "index_user_followers_on_following_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bed_time_histories", "users"
  add_foreign_key "user_followers", "users", column: "follower_id"
  add_foreign_key "user_followers", "users", column: "following_id"
end
