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

ActiveRecord::Schema.define(version: 2022_02_25_100000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "grading_set_images", force: :cascade do |t|
    t.bigint "grading_set_id", null: false
    t.bigint "image_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["grading_set_id"], name: "index_grading_set_images_on_grading_set_id"
    t.index ["image_id"], name: "index_grading_set_images_on_image_id"
  end

  create_table "grading_sets", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "image_files", force: :cascade do |t|
    t.bigint "image_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["image_id"], name: "index_image_files_on_image_id"
  end

  create_table "image_sources", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true, null: false
  end

  create_table "images", force: :cascade do |t|
    t.bigint "image_source_id", null: false
    t.text "filename", null: false
    t.text "mime_type", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "exif_data", default: {}, null: false
    t.index ["image_source_id"], name: "index_images_on_image_source_id"
  end

  create_table "user_grading_set_images", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "grading_set_image_id", null: false
    t.integer "grade", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["grading_set_image_id"], name: "index_user_grading_set_images_on_grading_set_image_id"
    t.index ["user_id"], name: "index_user_grading_set_images_on_user_id"
  end

  create_table "user_grading_sets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "grading_set_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["grading_set_id"], name: "index_user_grading_sets_on_grading_set_id"
    t.index ["user_id"], name: "index_user_grading_sets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "email", null: false
    t.text "login_token_hash"
    t.datetime "login_token_expires_at", precision: 6
    t.boolean "admin", default: false, null: false
    t.boolean "image_viewer", default: false, null: false
    t.boolean "image_admin", default: false, null: false
    t.boolean "grader", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "grading_set_images", "grading_sets"
  add_foreign_key "grading_set_images", "images"
  add_foreign_key "image_files", "images"
  add_foreign_key "images", "image_sources"
  add_foreign_key "user_grading_set_images", "grading_set_images"
  add_foreign_key "user_grading_set_images", "users"
  add_foreign_key "user_grading_sets", "grading_sets"
  add_foreign_key "user_grading_sets", "users"
end
