class BackgroundRefresh
  @queue = 'work'

  def self.perform(user_id)
    current_user = User.find(user_id)
    Post.refresh_cache!(current_user)
  end
end