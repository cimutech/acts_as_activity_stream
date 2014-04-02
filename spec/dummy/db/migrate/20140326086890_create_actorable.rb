class CreateActorable < ActiveRecord::Migration
  def change

    create_table "users", :force => true do |t|
      t.string   "name"
      t.string   "email",              :default => "",   :null => false
      t.string   "slug"
      t.string   "encrypted_password",     :limit => 128, :default => "",     :null => false
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
      t.datetime "created_at",                                                :null => false
      t.datetime "updated_at",                                                :null => false
    end

    add_index "users", ["slug"], :unique => true
    add_index "users", ["email"], :unique => true
    add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  end
end