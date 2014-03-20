class AddFeedUpdatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :feed_updated_at, :timestamp
  end
end
