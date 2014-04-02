class BackgroundRefresh
  include SuckerPunch::Job

  def perform(user_id)
    current_user = User.find(user_id)
    most_recent = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at
    ActiveRecord::Base.connection_pool.with_connection do
      Post.refresh_cache!(current_user)
      new_most_recent = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at
      unless new_most_recent == most_recent
        PrivatePub.publish_to("/messages/#{user_id}", "$('#new_posts_notification').show();")
      end
    end
  end
end