class BackgroundRefresh
  include SuckerPunch::Job

  def perform(user_id)
    current_user = User.find(user_id)
    if current_user.posts.any?
      old_top_post_date = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at
    end
    ActiveRecord::Base.connection_pool.with_connection do
      Post.refresh_cache!(current_user)
      new_top_post_date = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at

      unless new_top_post_date == old_top_post_date
        num_of_new_messages = current_user.posts.where("created_at > ?", old_top_post_date).count
        PrivatePub.publish_to("/messages/#{user_id}", "$('#new_posts_notification').show();document.getElementById('new_posts_count').innerHTML = #{num_of_new_messages};")
      end
    end
  end
end