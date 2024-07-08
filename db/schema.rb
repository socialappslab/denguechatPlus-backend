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

ActiveRecord::Schema[7.1].define(version: 2024_07_08_142044) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.bigint "state_id", null: false
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_cities_on_country_id"
    t.index ["name", "discarded_at"], name: "index_cities_on_name_and_discarded_at", unique: true
    t.index ["state_id", "country_id", "discarded_at"], name: "index_cities_on_state_id_and_country_id_and_discarded_at", unique: true
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_countries_on_discarded_at"
    t.index ["name"], name: "index_countries_on_name"
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.bigint "country_id", null: false
    t.bigint "state_id", null: false
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_neighborhoods_on_city_id"
    t.index ["country_id", "state_id", "city_id", "discarded_at"], name: "idx_on_country_id_state_id_city_id_discarded_at_d4d773c91a", unique: true
    t.index ["country_id"], name: "index_neighborhoods_on_country_id"
    t.index ["name", "discarded_at"], name: "index_neighborhoods_on_name_and_discarded_at", unique: true
    t.index ["state_id"], name: "index_neighborhoods_on_state_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_organizations_on_discarded_at"
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_type"
    t.bigint "resource_id"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "seed_tasks", force: :cascade do |t|
    t.string "task_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "discarded_at"], name: "index_states_on_country_id_and_discarded_at", unique: true
    t.index ["country_id"], name: "index_states_on_country_id"
    t.index ["name", "discarded_at"], name: "index_states_on_name_and_discarded_at", unique: true
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
    t.string "phone"
    t.string "username"
    t.boolean "status", default: false
    t.index ["discarded_at"], name: "index_user_accounts_on_discarded_at"
    t.index ["email"], name: "index_user_accounts_on_email", unique: true
    t.index ["phone"], name: "index_user_accounts_on_phone", unique: true
    t.index ["user_profile_id"], name: "index_user_accounts_on_user_profile_id"
    t.index ["username"], name: "index_user_accounts_on_username", unique: true
  end

  create_table "user_profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "gender"
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

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.string "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "cities", "countries"
  add_foreign_key "cities", "states"
  add_foreign_key "neighborhoods", "cities"
  add_foreign_key "neighborhoods", "countries"
  add_foreign_key "neighborhoods", "states"
  add_foreign_key "states", "countries"
  add_foreign_key "user_accounts", "user_profiles"
  add_foreign_key "user_profiles_roles", "roles"
  add_foreign_key "user_profiles_roles", "user_profiles"
end
