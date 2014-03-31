class BackgroundRefresh
  include SuckerPunch::Job

  def perform(user_id)
      ActiveRecord::Base.connection_pool.with_connection do
        current_user = User.find(user_id)
        Post.refresh_cache!(current_user)
      end
    end

  # @queue = 'work'

  # def self.perform(user_id)
  #   current_user = User.find(user_id)
  #   Post.refresh_cache!(current_user)
  # end
end