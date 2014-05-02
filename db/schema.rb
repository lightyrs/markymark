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

ActiveRecord::Schema.define(version: 20140502073022) do

  create_table "classifications", force: true do |t|
    t.string   "name"
    t.string   "content_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "classifications", ["content_type", "name"], name: "index_classifications_on_content_type_and_name", unique: true, using: :btree

  create_table "identities", force: true do |t|
    t.string   "uid"
    t.string   "username"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "token"
    t.integer  "provider_id"
    t.text     "secret"
  end

  add_index "identities", ["provider_id"], name: "identities_provider_id_fk", using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "links", force: true do |t|
    t.text     "title",              limit: 2147483647
    t.text     "description"
    t.text     "url"
    t.text     "image_url"
    t.text     "content",            limit: 2147483647
    t.string   "domain"
    t.datetime "posted_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "provider_id"
    t.text     "lede"
    t.text     "content_links",      limit: 2147483647
    t.text     "html_content",       limit: 2147483647
    t.text     "pismo_page",         limit: 2147483647
    t.text     "metainspector_page", limit: 2147483647
    t.boolean  "scraped",                               default: false
  end

  add_index "links", ["domain", "title"], name: "index_links_on_domain_and_title", unique: true, length: {"domain"=>nil, "title"=>100}, using: :btree
  add_index "links", ["provider_id"], name: "links_provider_id_fk", using: :btree
  add_index "links", ["user_id", "url"], name: "index_links_on_user_id_and_url", unique: true, length: {"user_id"=>nil, "url"=>100}, using: :btree

  create_table "providers", force: true do |t|
    t.string   "name"
    t.string   "domain"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "logged_in_at"
  end

  add_foreign_key "identities", "providers", name: "identities_provider_id_fk"
  add_foreign_key "identities", "users", name: "identities_user_id_fk"

  add_foreign_key "links", "providers", name: "links_provider_id_fk"
  add_foreign_key "links", "users", name: "links_user_id_fk"

end
