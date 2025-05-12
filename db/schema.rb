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

ActiveRecord::Schema[8.0].define(version: 2025_05_11_140507) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.integer "coach_profile_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.string "status", default: "available", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "student_id"
    t.index ["coach_profile_id", "start_time"], name: "index_availabilities_on_coach_profile_id_and_start_time"
    t.index ["coach_profile_id"], name: "index_availabilities_on_coach_profile_id"
    t.index ["student_id"], name: "index_availabilities_on_student_id"
  end

  create_table "coach_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "bio"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_coach_profiles_on_user_id", unique: true
  end

  create_table "coaching_sessions", force: :cascade do |t|
    t.integer "coach_profile_id"
    t.integer "student_id"
    t.integer "availability_id"
    t.string "status"
    t.integer "satisfaction_score"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["availability_id"], name: "index_coaching_sessions_on_availability_id"
    t.index ["coach_profile_id"], name: "index_coaching_sessions_on_coach_profile_id"
    t.index ["status"], name: "index_coaching_sessions_on_status"
    t.index ["student_id"], name: "index_coaching_sessions_on_student_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name"
    t.string "phone"
    t.string "timezone", default: "UTC", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end
end
