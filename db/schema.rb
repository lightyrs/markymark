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

ActiveRecord::Schema.define(version: 20140512010948) do

  create_table "alias_tags", id: false, force: :cascade do |t|
    t.integer "tag_id",   limit: 4
    t.integer "alias_id", limit: 4
  end

  add_index "alias_tags", ["alias_id"], name: "index_alias_tags_on_alias_id", using: :btree
  add_index "alias_tags", ["tag_id"], name: "index_alias_tags_on_tag_id", using: :btree

  create_table "classifications", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "content_type", limit: 255
    t.text     "description",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",         limit: 255
  end

  add_index "classifications", ["content_type", "name"], name: "index_classifications_on_content_type_and_name", unique: true, using: :btree

  create_table "identities", force: :cascade do |t|
    t.string   "uid",         limit: 255
    t.string   "username",    limit: 255
    t.integer  "user_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "token",       limit: 65535
    t.integer  "provider_id", limit: 4
    t.text     "secret",      limit: 65535
  end

  add_index "identities", ["provider_id"], name: "identities_provider_id_fk", using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "links", force: :cascade do |t|
    t.text     "title",         limit: 4294967295
    t.text     "description",   limit: 65535
    t.text     "url",           limit: 65535
    t.text     "image_url",     limit: 65535
    t.text     "content",       limit: 4294967295
    t.string   "domain",        limit: 255
    t.datetime "posted_at"
    t.integer  "user_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "provider_id",   limit: 4
    t.text     "lede",          limit: 65535
    t.text     "content_links", limit: 4294967295
    t.text     "html_content",  limit: 4294967295
    t.boolean  "scraped",       limit: 1,          default: false
    t.boolean  "completed",     limit: 1,          default: false
  end

  add_index "links", ["provider_id"], name: "links_provider_id_fk", using: :btree
  add_index "links", ["user_id", "url"], name: "index_links_on_user_id_and_url", unique: true, length: {"user_id"=>nil, "url"=>50}, using: :btree

  create_table "providers", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "domain",      limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "email",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "logged_in_at"
  end

  add_foreign_key "identities", "providers", name: "identities_provider_id_fk"
  add_foreign_key "identities", "users", name: "identities_user_id_fk"
  add_foreign_key "links", "providers", name: "links_provider_id_fk"
  add_foreign_key "links", "users", name: "links_user_id_fk"
end
