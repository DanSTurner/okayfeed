class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def show
    if twitter_client.user?(@user.twitter_username)
      tweets = twitter_client.user_timeline(@user.twitter_username, :count => 10)
    # twitter_client.user_timeline(@user.twitter_username)
      @tweets_text = tweets.map { |tweet| tweet.text }
    else
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end
end
