class CreateActorable < ActiveRecord::Migration
  def change

    create_table "users", :force => true do |t|
      t.string   "name"
      t.string   "email",              :default => "",   :null => false
      t.datetime "created_at",                                                :null => false
      t.datetime "updated_at",                                                :null => false
    end

    add_index "users", ["email"], :unique => true

  end
end