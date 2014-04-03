class BackgroundRefresh
  include SuckerPunch::Job

  def perform(user_id)
    current_user = User.find(user_id)
    old_top_post_date = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at
    ActiveRecord::Base.connection_pool.with_connection do
      Post.refresh_cache!(current_user)
      new_top_post_date = current_user.posts.all.sort_by(&:created_at).reverse.first.created_at

      unless new_top_post_date == old_top_post_date
        old_top_post_new_id = current_user.posts.find_by(created_at: old_top_post_date).id
        range = (current_user.posts.sort_by(&:created_at).reverse.first.id)..old_top_post_new_id
        num_of_new_messages = current_user.posts.where('id' => range).count - 1

        PrivatePub.publish_to("/messages/#{user_id}", "$('#new_posts_notification').show();document.getElementById('new_posts_count').innerHTML = #{num_of_new_messages};")
      end
    end
  end
end