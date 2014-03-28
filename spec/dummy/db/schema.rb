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

ActiveRecord::Schema.define(:version => 20140326086890) do

  create_table "activities", :force => true do |t|
    t.integer  "activable_id"
    t.string   "activable_type"
    t.integer  "author_id"
    t.integer  "owner_id"
    t.integer  "comment_count",  :default => 0
    t.integer  "integer",        :default => 0
    t.string   "verb"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "activities", ["author_id"], :name => "index_activities_on_author_id"
  add_index "activities", ["owner_id"], :name => "index_activities_on_owner_id"

  create_table "actors", :force => true do |t|
    t.integer  "actorable_id"
    t.string   "actorable_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "actors", ["actorable_type", "actorable_id"], :name => "index_actors_on_actorable_type_and_actorable_id", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "title",            :default => ""
    t.text     "body",             :default => ""
    t.integer  "sender_id",                        :null => false
    t.integer  "parent_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "contacts", :force => true do |t|
    t.integer  "sender_id",                     :null => false
    t.integer  "receiver_id",                   :null => false
    t.boolean  "blocked",     :default => true
    t.integer  "inverse_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "contacts", ["blocked"], :name => "index_contacts_on_blocked"
  add_index "contacts", ["inverse_id"], :name => "index_contacts_on_inverse_id"
  add_index "contacts", ["receiver_id"], :name => "index_contacts_on_receiver_id"
  add_index "contacts", ["sender_id", "receiver_id"], :name => "index_contacts_on_sender_id_and_receiver_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email",                                 :default => "", :null => false
    t.string   "slug"
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "password_salt"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

end
