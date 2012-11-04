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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121104182855) do

  create_table "books", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_synced_at"
    t.string   "goodreads_link"
    t.string   "image_url"
    t.string   "small_image_url"
  end

  create_table "copies", :force => true do |t|
    t.string   "title"
    t.string   "author"
    t.string   "call_number"
    t.integer  "book_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_synced_at"
    t.integer  "location_id"
  end

  create_table "library_systems", :force => true do |t|
    t.string   "search_bot_class"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "library_systems_users", :force => true do |t|
    t.integer "library_system_id"
    t.integer "user_id"
  end

  create_table "locations", :force => true do |t|
    t.integer  "library_system_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations_users", :force => true do |t|
    t.integer "location_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "oauth_access_token"
    t.string   "oauth_access_secret"
    t.string   "goodreads_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_synced_at"
    t.text     "shelves"
    t.text     "active_shelves"
  end

end
