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

ActiveRecord::Schema[7.1].define(version: 2024_06_18_015203) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_type"
    t.bigint "resource_id"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "user_accounts", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean "locked", default: false, null: false
    t.datetime "locked_at"
    t.datetime "discarded_at"
    t.bigint "user_profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_user_accounts_on_discarded_at"
    t.index ["email"], name: "index_user_accounts_on_email", unique: true
    t.index ["user_profile_id"], name: "index_user_accounts_on_user_profile_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "gender"
    t.string "phone_number"
    t.string "slug"
    t.integer "points"
    t.string "country"
    t.string "city"
    t.string "language"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_profiles_roles", force: :cascade do |t|
    t.bigint "user_profile_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_profiles_roles_on_role_id"
    t.index ["user_profile_id"], name: "index_user_profiles_roles_on_user_profile_id"
  end

  add_foreign_key "user_accounts", "user_profiles"
  add_foreign_key "user_profiles_roles", "roles"
  add_foreign_key "user_profiles_roles", "user_profiles"
end
