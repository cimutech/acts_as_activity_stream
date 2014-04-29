class CreateActsAsActivityStream < ActiveRecord::Migration
  def change
    create_table :activities, :force => true do |t|
      t.references :activable, :polymorphic => true
      t.integer    :author_id
      t.integer    :comments_count, :default => 0
      t.integer    :likes_count, :default => 0
      t.string     :verb
      t.timestamps
    end

    add_index :activities, :author_id
    add_index :activities, [:activable_type, :activable_id]

    create_table :actors, :force => true do |t|
      t.references :actorable, :polymorphic => true
      t.timestamps
    end

    add_index :actors, [:actorable_type, :actorable_id], :unique => true

    create_table :contacts, :force => true do |t|
      t.integer :sender_id, :null => false
      t.integer :receiver_id, :null => false
      t.boolean :blocked, :default => true
      t.integer :inverse_id
      t.timestamps
    end

    add_index :contacts, [:sender_id, :receiver_id], :unique => true
    add_index :contacts, :receiver_id
    add_index :contacts, :blocked
    add_index :contacts, :inverse_id

    create_table :posts, :force => true do |t|
      t.string     :title, :default => ""
      t.text       :body, :default => ""
      t.integer    :sender_id, :null => false
      t.timestamps
    end

    add_index :posts, :sender_id

    create_table :likes, :force => true do |t|
      t.references :likable, :polymorphic => true
      t.integer    :sender_id, :null => false
      t.timestamps
    end

    add_index :likes, [:likable_type, :likable_id], :unique => true
    add_index :likes, :sender_id


    create_table :comments, :force => true do |t|
      t.references :commentable, :polymorphic => true
      t.string     :title, :default => ""
      t.text       :body, :default => ""
      t.integer    :sender_id, :null => false
      t.integer    :parent_id
      t.timestamps
    end

    add_index :comments, [:commentable_type, :commentable_id]
    add_index :comments, :sender_id
    add_index :comments, :parent_id

  end
end
