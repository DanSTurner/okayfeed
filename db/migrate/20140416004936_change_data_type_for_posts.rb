class ChangeDataTypeForPosts < ActiveRecord::Migration
  def change
    change_table :posts do |t|
      t.change :link,           :text, limit: nil
      t.change :user_url,       :text, limit: nil
      t.change :user_image_url, :text, limit: nil
      t.change :picture_url,    :text, limit: nil
      t.change :url,            :text, limit: nil
      t.change :name,           :text, limit: nil
    end
  end
end
