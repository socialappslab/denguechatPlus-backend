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

ActiveRecord::Schema[7.1].define(version: 2024_08_08_035809) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "breeding_site_types", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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

  create_table "configurations", force: :cascade do |t|
    t.string "field_name", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "container_types", force: :cascade do |t|
    t.string "name"
    t.bigint "breeding_site_type_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["breeding_site_type_id"], name: "index_container_types_on_breeding_site_type_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_countries_on_discarded_at"
    t.index ["name"], name: "index_countries_on_name"
  end

  create_table "create_visit_param_versions", force: :cascade do |t|
    t.string "name"
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "elimination_method_types", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "house_blocks", force: :cascade do |t|
    t.datetime "discarded_at"
    t.bigint "team_id", null: false
    t.bigint "user_profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["team_id"], name: "index_house_blocks_on_team_id"
    t.index ["user_profile_id"], name: "index_house_blocks_on_user_profile_id"
  end

  create_table "houses", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.bigint "state_id", null: false
    t.bigint "city_id", null: false
    t.bigint "neighborhood_id", null: false
    t.bigint "wedge_id", null: false
    t.bigint "house_block_id"
    t.bigint "special_place_id"
    t.bigint "team_id"
    t.bigint "user_profile_id", null: false
    t.datetime "discarded_at"
    t.string "reference_code"
    t.string "house_type"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.string "notes"
    t.string "status"
    t.integer "container_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_houses_on_city_id"
    t.index ["country_id"], name: "index_houses_on_country_id"
    t.index ["house_block_id"], name: "index_houses_on_house_block_id"
    t.index ["neighborhood_id"], name: "index_houses_on_neighborhood_id"
    t.index ["special_place_id"], name: "index_houses_on_special_place_id"
    t.index ["state_id"], name: "index_houses_on_state_id"
    t.index ["team_id"], name: "index_houses_on_team_id"
    t.index ["user_profile_id"], name: "index_houses_on_user_profile_id"
    t.index ["wedge_id"], name: "index_houses_on_wedge_id"
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.bigint "country_id", null: false
    t.bigint "state_id", null: false
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "wedge_id"
    t.index ["city_id"], name: "index_neighborhoods_on_city_id"
    t.index ["country_id", "state_id", "city_id", "discarded_at"], name: "idx_on_country_id_state_id_city_id_discarded_at_d4d773c91a", unique: true
    t.index ["country_id"], name: "index_neighborhoods_on_country_id"
    t.index ["name", "discarded_at"], name: "index_neighborhoods_on_name_and_discarded_at", unique: true
    t.index ["state_id"], name: "index_neighborhoods_on_state_id"
    t.index ["wedge_id"], name: "index_neighborhoods_on_wedge_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_organizations_on_discarded_at"
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name"
    t.string "resource"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "roles_permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.index ["permission_id", "role_id"], name: "index_roles_permissions_on_permission_id_and_role_id", unique: true
    t.index ["permission_id"], name: "index_roles_permissions_on_permission_id"
    t.index ["role_id"], name: "index_roles_permissions_on_role_id"
  end

  create_table "seed_tasks", force: :cascade do |t|
    t.string "task_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "special_places", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
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

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.boolean "locked", default: false
    t.integer "points", default: 0
    t.datetime "deleted_at"
    t.bigint "organization_id", null: false
    t.bigint "neighborhood_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "leader_id"
    t.bigint "wedge_id"
    t.index ["leader_id"], name: "index_teams_on_leader_id"
    t.index ["name", "deleted_at"], name: "index_teams_on_name_and_deleted_at", unique: true
    t.index ["neighborhood_id"], name: "index_teams_on_neighborhood_id"
    t.index ["organization_id"], name: "index_teams_on_organization_id"
    t.index ["wedge_id"], name: "index_teams_on_wedge_id"
  end

  create_table "user_accounts", force: :cascade do |t|
    t.string "password_digest"
    t.datetime "discarded_at"
    t.bigint "user_profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.string "username"
    t.integer "status", default: 0
    t.integer "failed_attempts", default: 0
    t.index ["discarded_at"], name: "index_user_accounts_on_discarded_at"
    t.index ["phone"], name: "index_user_accounts_on_phone", unique: true
    t.index ["user_profile_id"], name: "index_user_accounts_on_user_profile_id"
    t.index ["username"], name: "index_user_accounts_on_username", unique: true
  end

  create_table "user_accounts_roles", id: false, force: :cascade do |t|
    t.bigint "user_account_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_user_accounts_roles_on_role_id"
    t.index ["user_account_id", "role_id"], name: "index_user_accounts_roles_on_user_account_id_and_role_id"
    t.index ["user_account_id"], name: "index_user_accounts_roles_on_user_account_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "gender"
    t.integer "points"
    t.string "language"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.bigint "city_id"
    t.bigint "neighborhood_id"
    t.bigint "organization_id"
    t.bigint "team_id"
    t.index ["city_id"], name: "index_user_profiles_on_city_id"
    t.index ["neighborhood_id"], name: "index_user_profiles_on_neighborhood_id"
    t.index ["organization_id"], name: "index_user_profiles_on_organization_id"
    t.index ["team_id"], name: "index_user_profiles_on_team_id"
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

  create_table "visit_param_versions", force: :cascade do |t|
    t.string "name"
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "water_source_types", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wedges", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.bigint "neighborhood_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["neighborhood_id", "discarded_at"], name: "index_wedges_on_neighborhood_id_and_discarded_at", unique: true
    t.index ["neighborhood_id"], name: "index_wedges_on_neighborhood_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cities", "countries"
  add_foreign_key "cities", "states"
  add_foreign_key "container_types", "breeding_site_types"
  add_foreign_key "house_blocks", "teams"
  add_foreign_key "house_blocks", "user_profiles"
  add_foreign_key "houses", "cities"
  add_foreign_key "houses", "countries"
  add_foreign_key "houses", "house_blocks"
  add_foreign_key "houses", "neighborhoods"
  add_foreign_key "houses", "special_places"
  add_foreign_key "houses", "states"
  add_foreign_key "houses", "teams"
  add_foreign_key "houses", "user_profiles"
  add_foreign_key "houses", "wedges"
  add_foreign_key "neighborhoods", "cities"
  add_foreign_key "neighborhoods", "countries"
  add_foreign_key "neighborhoods", "states"
  add_foreign_key "neighborhoods", "wedges"
  add_foreign_key "states", "countries"
  add_foreign_key "teams", "neighborhoods"
  add_foreign_key "teams", "organizations"
  add_foreign_key "teams", "user_profiles", column: "leader_id"
  add_foreign_key "teams", "wedges"
  add_foreign_key "user_accounts", "user_profiles"
  add_foreign_key "user_profiles", "cities"
  add_foreign_key "user_profiles", "neighborhoods"
  add_foreign_key "user_profiles", "organizations"
  add_foreign_key "user_profiles", "teams"
  add_foreign_key "wedges", "neighborhoods"
end
