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

ActiveRecord::Schema[7.1].define(version: 2025_05_30_045757) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

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

  create_table "app_config_params", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "param_source"
    t.string "param_type"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["name"], name: "index_app_config_params_on_name", unique: true
    t.index ["param_source", "name"], name: "index_app_config_params_on_param_source_and_name"
  end

  create_table "breeding_site_type_aditional_informations", force: :cascade do |t|
    t.string "description"
    t.boolean "only_image"
    t.string "title"
    t.string "subtitle"
    t.bigint "breeding_site_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["breeding_site_type_id"], name: "idx_on_breeding_site_type_id_a588ef2362"
  end

  create_table "breeding_site_types", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "container_type"
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

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.integer "likes_count"
    t.bigint "post_id", null: false
    t.bigint "user_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_comments_on_discarded_at"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_account_id"], name: "index_comments_on_user_account_id"
  end

  create_table "configurations", force: :cascade do |t|
    t.string "field_name", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "container_protections", force: :cascade do |t|
    t.string "name_es"
    t.string "name_en"
    t.string "name_pt"
    t.string "color"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_countries_on_discarded_at"
    t.index ["name"], name: "index_countries_on_name"
  end

  create_table "elimination_method_types", force: :cascade do |t|
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_es"
    t.string "name_en"
    t.string "name_pt"
  end

  create_table "house_block_wedges", force: :cascade do |t|
    t.bigint "house_block_id", null: false
    t.bigint "wedge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["house_block_id", "wedge_id"], name: "index_house_block_wedges_on_house_block_id_and_wedge_id", unique: true
    t.index ["house_block_id"], name: "index_house_block_wedges_on_house_block_id"
    t.index ["wedge_id"], name: "index_house_block_wedges_on_wedge_id"
  end

  create_table "house_blocks", force: :cascade do |t|
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "external_id"
    t.string "source"
    t.datetime "last_sync_time"
    t.bigint "neighborhood_id"
    t.index ["neighborhood_id"], name: "index_house_blocks_on_neighborhood_id"
  end

  create_table "house_statuses", force: :cascade do |t|
    t.bigint "house_id"
    t.bigint "house_block_id"
    t.bigint "wedge_id"
    t.bigint "neighborhood_id"
    t.bigint "city_id"
    t.bigint "country_id"
    t.bigint "team_id"
    t.integer "infected_containers", default: 0
    t.integer "non_infected_containers", default: 0
    t.integer "potential_containers", default: 0
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_visit"
    t.string "status"
    t.index ["city_id"], name: "index_house_statuses_on_city_id"
    t.index ["country_id"], name: "index_house_statuses_on_country_id"
    t.index ["house_block_id"], name: "index_house_statuses_on_house_block_id"
    t.index ["house_id"], name: "index_house_statuses_on_house_id"
    t.index ["neighborhood_id"], name: "index_house_statuses_on_neighborhood_id"
    t.index ["team_id"], name: "index_house_statuses_on_team_id"
    t.index ["wedge_id"], name: "index_house_statuses_on_wedge_id"
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
    t.bigint "user_profile_id"
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
    t.datetime "last_visit"
    t.integer "infected_containers"
    t.integer "non_infected_containers"
    t.integer "potential_containers"
    t.string "location_status"
    t.boolean "tariki_status", default: false
    t.string "external_id"
    t.integer "assignment_status"
    t.string "source"
    t.datetime "last_sync_time"
    t.integer "consecutive_green_status", default: 0
    t.index ["city_id"], name: "index_houses_on_city_id"
    t.index ["country_id"], name: "index_houses_on_country_id"
    t.index ["house_block_id"], name: "index_houses_on_house_block_id"
    t.index ["neighborhood_id"], name: "index_houses_on_neighborhood_id"
    t.index ["reference_code"], name: "index_houses_on_reference_code", unique: true
    t.index ["special_place_id"], name: "index_houses_on_special_place_id"
    t.index ["state_id"], name: "index_houses_on_state_id"
    t.index ["team_id"], name: "index_houses_on_team_id"
    t.index ["user_profile_id"], name: "index_houses_on_user_profile_id"
    t.index ["wedge_id"], name: "index_houses_on_wedge_id"
  end

  create_table "inspection_container_protections", force: :cascade do |t|
    t.bigint "inspection_id"
    t.bigint "container_protection_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["container_protection_id"], name: "idx_on_container_protection_id_2b631ae959"
    t.index ["inspection_id"], name: "index_inspection_container_protections_on_inspection_id"
  end

  create_table "inspection_water_source_types", force: :cascade do |t|
    t.bigint "inspection_id", null: false
    t.bigint "water_source_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inspection_id", "water_source_type_id"], name: "idx_on_inspection_id_water_source_type_id_36033ead1d", unique: true
    t.index ["inspection_id"], name: "index_inspection_water_source_types_on_inspection_id"
    t.index ["water_source_type_id"], name: "index_inspection_water_source_types_on_water_source_type_id"
  end

  create_table "inspections", force: :cascade do |t|
    t.bigint "visit_id", null: false
    t.bigint "breeding_site_type_id", null: false
    t.bigint "elimination_method_type_id"
    t.bigint "created_by_id", null: false
    t.bigint "treated_by_id", null: false
    t.string "code_reference"
    t.boolean "has_water"
    t.string "container_test_result"
    t.string "tracking_type_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "water_source_other"
    t.string "lid_type"
    t.string "lid_type_other"
    t.string "other_protection"
    t.string "was_chemically_treated"
    t.string "other_elimination_method"
    t.string "color"
    t.string "location"
    t.datetime "discarded_at"
    t.index ["breeding_site_type_id"], name: "index_inspections_on_breeding_site_type_id"
    t.index ["created_by_id"], name: "index_inspections_on_created_by_id"
    t.index ["discarded_at"], name: "index_inspections_on_discarded_at"
    t.index ["elimination_method_type_id"], name: "index_inspections_on_elimination_method_type_id"
    t.index ["treated_by_id"], name: "index_inspections_on_treated_by_id"
    t.index ["visit_id"], name: "index_inspections_on_visit_id"
  end

  create_table "inspections_type_contents", id: false, force: :cascade do |t|
    t.bigint "inspection_id"
    t.bigint "type_content_id"
    t.index ["inspection_id"], name: "index_inspections_type_contents_on_inspection_id"
    t.index ["type_content_id"], name: "index_inspections_type_contents_on_type_content_id"
  end

  create_table "likes", force: :cascade do |t|
    t.string "likeable_type", null: false
    t.bigint "likeable_id", null: false
    t.bigint "user_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable"
    t.index ["user_account_id"], name: "index_likes_on_user_account_id"
  end

  create_table "neighborhood_wedges", force: :cascade do |t|
    t.bigint "neighborhood_id", null: false
    t.bigint "wedge_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["neighborhood_id", "wedge_id", "discarded_at"], name: "idx_on_neighborhood_id_wedge_id_discarded_at_29b7affea4", unique: true
    t.index ["neighborhood_id"], name: "index_neighborhood_wedges_on_neighborhood_id"
    t.index ["wedge_id"], name: "index_neighborhood_wedges_on_wedge_id"
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
    t.integer "external_id"
    t.string "source"
    t.datetime "last_sync_time"
    t.index ["city_id"], name: "index_neighborhoods_on_city_id"
    t.index ["country_id", "state_id", "city_id", "discarded_at"], name: "idx_on_country_id_state_id_city_id_discarded_at_d4d773c91a", unique: true
    t.index ["country_id"], name: "index_neighborhoods_on_country_id"
    t.index ["name", "discarded_at"], name: "index_neighborhoods_on_name_and_discarded_at", unique: true
    t.index ["state_id"], name: "index_neighborhoods_on_state_id"
    t.index ["wedge_id"], name: "index_neighborhoods_on_wedge_id"
  end

  create_table "options", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "name_es"
    t.boolean "required", default: false
    t.integer "next"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_en"
    t.string "name_pt"
    t.integer "resource_id"
    t.string "group_es"
    t.string "group_en"
    t.string "group_pt"
    t.string "type_option"
    t.string "status_color"
    t.string "value"
    t.boolean "disable_other_options", default: false
    t.integer "position"
    t.string "show_in_case"
    t.string "selected_case"
    t.integer "weighted_points"
    t.index ["question_id"], name: "index_options_on_question_id"
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

  create_table "points", force: :cascade do |t|
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pointable_type"
    t.bigint "pointable_id"
    t.integer "house_id"
    t.integer "visit_id"
    t.index ["pointable_type", "pointable_id"], name: "index_points_on_pointable_type_and_pointable_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "content"
    t.integer "likes_count"
    t.bigint "user_account_id", null: false
    t.bigint "team_id", null: false
    t.bigint "neighborhood_id", null: false
    t.bigint "city_id", null: false
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.string "location"
    t.integer "comments_count", default: 0
    t.string "visibility", default: "public"
    t.index ["city_id"], name: "index_posts_on_city_id"
    t.index ["country_id"], name: "index_posts_on_country_id"
    t.index ["discarded_at"], name: "index_posts_on_discarded_at"
    t.index ["neighborhood_id"], name: "index_posts_on_neighborhood_id"
    t.index ["team_id"], name: "index_posts_on_team_id"
    t.index ["user_account_id"], name: "index_posts_on_user_account_id"
  end

  create_table "questionnaires", force: :cascade do |t|
    t.string "name"
    t.boolean "current_form"
    t.datetime "discarded_at"
    t.integer "initial_question"
    t.integer "final_question"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "questionnaire_id", null: false
    t.string "question_text_es"
    t.string "description_es"
    t.string "type_field"
    t.integer "next"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description_en"
    t.string "description_pt"
    t.string "question_text_en"
    t.string "question_text_pt"
    t.string "resource_name"
    t.string "resource_type"
    t.string "notes_es"
    t.string "notes_en"
    t.string "notes_pt"
    t.boolean "required", default: true
    t.integer "parent_id"
    t.boolean "visible", default: true, null: false
    t.index ["parent_id"], name: "index_questions_on_parent_id"
    t.index ["questionnaire_id"], name: "index_questions_on_questionnaire_id"
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
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_es"
    t.string "name_en"
    t.string "name_pt"
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

  create_table "sync_log_errors", force: :cascade do |t|
    t.string "item_id"
    t.string "message"
    t.bigint "sync_log_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sync_log_id"], name: "index_sync_log_errors_on_sync_log_id"
  end

  create_table "sync_logs", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "processed"
    t.integer "errors_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "houses_updated"
    t.integer "houses_created"
    t.integer "house_blocks_updated"
    t.integer "house_blocks_created"
    t.integer "wedges_updated"
    t.integer "wedges_created"
    t.integer "sectors_updated"
    t.integer "sectors_created"
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
    t.bigint "wedge_id"
    t.bigint "city_id"
    t.index ["city_id"], name: "index_teams_on_city_id"
    t.index ["name", "deleted_at"], name: "index_teams_on_name_and_deleted_at", unique: true
    t.index ["neighborhood_id"], name: "index_teams_on_neighborhood_id"
    t.index ["organization_id"], name: "index_teams_on_organization_id"
    t.index ["wedge_id"], name: "index_teams_on_wedge_id"
  end

  create_table "type_contents", force: :cascade do |t|
    t.string "name_es"
    t.string "name_en"
    t.string "name_pt"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "code_recovery_sent_at"
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

  create_table "user_code_recoveries", force: :cascade do |t|
    t.integer "user_account_id"
    t.string "code"
    t.datetime "expired_at"
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_profile_house_blocks", force: :cascade do |t|
    t.bigint "user_profile_id", null: false
    t.bigint "house_block_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["house_block_id"], name: "index_user_profile_house_blocks_on_house_block_id"
    t.index ["user_profile_id"], name: "index_user_profile_house_blocks_on_user_profile_id"
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

  create_table "user_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "used_at"
    t.integer "user_account_id"
    t.string "data_type"
    t.string "event"
    t.string "user_code_recovery_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "visits", force: :cascade do |t|
    t.bigint "house_id", null: false
    t.datetime "visited_at"
    t.bigint "user_account_id", null: false
    t.bigint "team_id", null: false
    t.boolean "visit_permission", default: false
    t.string "notes"
    t.string "host"
    t.jsonb "questions"
    t.bigint "questionnaire_id", null: false
    t.jsonb "answers"
    t.integer "visit_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.integer "inspection_quantity"
    t.integer "inspection_with_pupae"
    t.integer "inspection_with_eggs"
    t.integer "inspection_with_larvae"
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_visits_on_discarded_at"
    t.index ["house_id"], name: "index_visits_on_house_id"
    t.index ["questionnaire_id"], name: "index_visits_on_questionnaire_id"
    t.index ["team_id"], name: "index_visits_on_team_id"
    t.index ["user_account_id"], name: "index_visits_on_user_account_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "external_id"
    t.string "source"
    t.datetime "last_sync_time"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "breeding_site_type_aditional_informations", "breeding_site_types"
  add_foreign_key "cities", "countries"
  add_foreign_key "cities", "states"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "user_accounts"
  add_foreign_key "house_block_wedges", "house_blocks"
  add_foreign_key "house_block_wedges", "wedges"
  add_foreign_key "house_blocks", "neighborhoods"
  add_foreign_key "house_statuses", "cities"
  add_foreign_key "house_statuses", "countries"
  add_foreign_key "house_statuses", "house_blocks"
  add_foreign_key "house_statuses", "houses"
  add_foreign_key "house_statuses", "neighborhoods"
  add_foreign_key "house_statuses", "teams"
  add_foreign_key "house_statuses", "wedges"
  add_foreign_key "houses", "cities"
  add_foreign_key "houses", "countries"
  add_foreign_key "houses", "house_blocks"
  add_foreign_key "houses", "neighborhoods"
  add_foreign_key "houses", "special_places"
  add_foreign_key "houses", "states"
  add_foreign_key "houses", "teams"
  add_foreign_key "houses", "user_profiles"
  add_foreign_key "houses", "wedges"
  add_foreign_key "inspection_container_protections", "container_protections"
  add_foreign_key "inspection_container_protections", "inspections"
  add_foreign_key "inspection_water_source_types", "inspections"
  add_foreign_key "inspection_water_source_types", "water_source_types"
  add_foreign_key "inspections", "breeding_site_types"
  add_foreign_key "inspections", "elimination_method_types"
  add_foreign_key "inspections", "user_accounts", column: "created_by_id"
  add_foreign_key "inspections", "user_accounts", column: "treated_by_id"
  add_foreign_key "inspections", "visits"
  add_foreign_key "inspections_type_contents", "inspections"
  add_foreign_key "inspections_type_contents", "type_contents"
  add_foreign_key "likes", "user_accounts"
  add_foreign_key "neighborhood_wedges", "neighborhoods"
  add_foreign_key "neighborhood_wedges", "wedges"
  add_foreign_key "neighborhoods", "cities"
  add_foreign_key "neighborhoods", "countries"
  add_foreign_key "neighborhoods", "states"
  add_foreign_key "neighborhoods", "wedges"
  add_foreign_key "options", "questions"
  add_foreign_key "posts", "cities"
  add_foreign_key "posts", "countries"
  add_foreign_key "posts", "neighborhoods"
  add_foreign_key "posts", "teams"
  add_foreign_key "posts", "user_accounts"
  add_foreign_key "questions", "questionnaires"
  add_foreign_key "states", "countries"
  add_foreign_key "sync_log_errors", "sync_logs"
  add_foreign_key "teams", "cities"
  add_foreign_key "teams", "neighborhoods"
  add_foreign_key "teams", "organizations"
  add_foreign_key "teams", "wedges"
  add_foreign_key "user_accounts", "user_profiles"
  add_foreign_key "user_profile_house_blocks", "house_blocks"
  add_foreign_key "user_profile_house_blocks", "user_profiles"
  add_foreign_key "user_profiles", "cities"
  add_foreign_key "user_profiles", "neighborhoods"
  add_foreign_key "user_profiles", "organizations"
  add_foreign_key "user_profiles", "teams"
  add_foreign_key "visits", "houses"
  add_foreign_key "visits", "questionnaires"
  add_foreign_key "visits", "teams"
  add_foreign_key "visits", "user_accounts"
end
