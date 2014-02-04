class UsersController < ApplicationController
  before_action :set_user,             only: [:show]
  before_action :set_authorizations,   only: [:show]

  def show
    if twitter_client.user?(@twitter.uid.to_i)
      tweets = twitter_client.user_timeline(@twitter.uid.to_i, :count => 10)
    # twitter_client.user_timeline(@user.twitter_username)
      @tweets_text = tweets.map { |tweet| tweet.text }
    else
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def set_authorizations
      @twitter = @user.authorizations.find_by(provider: 'twitter')
    end
end
