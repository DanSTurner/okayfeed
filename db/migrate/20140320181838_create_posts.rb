class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.string :provider
      t.string :user_screen_name
      t.string :user_name
      t.string :user_url
      t.string :user_image_url
      t.text :text
      t.string :url
      t.datetime :created_at
      t.string :picture_url
      t.string :link
      t.string :name
      t.text :link_caption
      t.text :story

      t.timestamps
    end
    add_index :posts, :user_id
  end
end
