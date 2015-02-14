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

ActiveRecord::Schema.define(version: 20150214181455) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.integer  "user_id"
    t.string   "author",          limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "goodreads_link",  limit: 255
    t.string   "image_url",       limit: 255
    t.string   "small_image_url", limit: 255
    t.datetime "last_synced_at"
    t.json     "sync_errors",                 default: {}, null: false
  end

  create_table "copies", force: :cascade do |t|
    t.text     "title"
    t.text     "author"
    t.string   "call_number",    limit: 255
    t.integer  "book_id"
    t.string   "status",         limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "last_synced_at"
    t.integer  "location_id"
    t.text     "url"
  end

  create_table "library_systems", force: :cascade do |t|
    t.string   "search_bot_class", limit: 255
    t.string   "name",             limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "library_systems_users", force: :cascade do |t|
    t.integer "library_system_id"
    t.integer "user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "library_system_id", limit: 255
    t.string   "name",              limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "locations_users", force: :cascade do |t|
    t.integer "location_id"
    t.integer "user_id"
  end

  create_table "shelvings", force: :cascade do |t|
    t.integer  "book_id"
    t.integer  "user_id"
    t.datetime "synced_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "oauth_access_token",  limit: 255
    t.string   "oauth_access_secret", limit: 255
    t.string   "goodreads_id",        limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.datetime "last_synced_at"
    t.text     "shelves"
    t.text     "active_shelves"
    t.string   "library_system_ids",              default: [],              array: true
  end

  add_foreign_key "copies", "books", name: "fk_copies_books"
end
