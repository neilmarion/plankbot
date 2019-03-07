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

ActiveRecord::Schema.define(version: 20190308051035) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "plankbot_labels", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plankbot_pull_request_label_relationships", force: :cascade do |t|
    t.integer  "pull_request_id"
    t.integer  "label_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["label_id"], name: "index_plankbot_pr_on_label_id", using: :btree
    t.index ["pull_request_id", "label_id"], name: "prlr_pr_id_label_id", unique: true, using: :btree
    t.index ["pull_request_id"], name: "index_plankbot_label_on_pr_id", using: :btree
  end

  create_table "plankbot_pull_request_reviewer_relationships", force: :cascade do |t|
    t.integer  "reviewer_id"
    t.integer  "pull_request_id"
    t.datetime "approved_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["pull_request_id"], name: "index_plankbot_prrr_on_pull_request_id", using: :btree
    t.index ["reviewer_id", "pull_request_id"], name: "prrr_reviewer_id_pr_id", unique: true, using: :btree
    t.index ["reviewer_id"], name: "index_plankbot_prrr_on_reviewer_id", using: :btree
  end

  create_table "plankbot_pull_requests", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.string   "github_id"
    t.integer  "requestor_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "plankbot_reviewer_tag_relationships", force: :cascade do |t|
    t.integer  "reviewer_id"
    t.integer  "tag_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["reviewer_id", "tag_id"], name: "rtr_reviewer_id_tag_id", unique: true, using: :btree
    t.index ["reviewer_id"], name: "index_plankbot_reviewer_tag_relationships_on_reviewer_id", using: :btree
    t.index ["tag_id"], name: "index_plankbot_reviewer_tag_relationships_on_tag_id", using: :btree
  end

  create_table "plankbot_reviewers", force: :cascade do |t|
    t.string   "name"
    t.string   "slack_id"
    t.string   "github_id"
    t.boolean  "available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plankbot_settings", force: :cascade do |t|
    t.text     "shutdown_times",     default: [],              array: true
    t.text     "shutdown_week_days", default: [],              array: true
    t.text     "shutdown_dates",     default: [],              array: true
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "plankbot_tags", force: :cascade do |t|
    t.string   "name"
    t.string   "kind"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
