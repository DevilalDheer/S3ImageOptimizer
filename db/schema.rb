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

ActiveRecord::Schema.define(version: 20151205071759) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "tablefunc"
  enable_extension "adminpack"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dir_paths", force: :cascade do |t|
    t.string   "path",                                  null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "invalidate_cloudfront", default: false, null: false
  end

  add_index "dir_paths", ["path"], name: "index_dir_paths_on_path", unique: true, using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "path",                          null: false
    t.string   "original_size"
    t.string   "current_size"
    t.boolean  "optimized",     default: false, null: false
    t.boolean  "modified",      default: false, null: false
    t.integer  "dir_path_id",                   null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "original"
    t.boolean  "zoom"
    t.boolean  "large"
    t.boolean  "small"
    t.boolean  "small_m"
    t.boolean  "large_m"
    t.string   "content_type"
  end

  add_index "images", ["dir_path_id"], name: "index_images_on_dir_path_id", using: :btree
  add_index "images", ["path"], name: "index_images_on_path", unique: true, using: :btree

  add_foreign_key "images", "dir_paths"
end
