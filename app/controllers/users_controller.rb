class UsersController < ApplicationController
  before_action :set_user,             only: [:show, :publish]
  before_action :set_authorizations,   only: [:show, :publish]

  def show
    if @user.authorizations.find_by(provider: "twitter") && twitter_client.user?(@twitter.uid.to_i)
      tweets = twitter_client.home_timeline
      @tweets_text = tweets.map { |tweet| tweet.text }
    end
    # if @user.authorizations.find_by(provider: "twitter") && twitter_client.user?(@twitter.uid.to_i)
    #   tweets = twitter_client.home_timeline
    #   @tweets_text = tweets.map { |tweet| tweet.text }
    # end
  end

  def publish
    @content = params[:content]
    twitter_client.update(@content)
    redirect_to user_path(@user)
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def set_authorizations
      @twitter = @user.authorizations.find_by(provider: 'twitter')
    end

    def twitter_client
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key         = ENV["CONSUMER_KEY"]
        config.consumer_secret      = ENV["CONSUMER_SECRET"]
        config.access_token         = @twitter.token
        config.access_token_secret  = @twitter.secret
      end
    end
end
