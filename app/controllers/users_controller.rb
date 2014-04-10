# require './workers/background_refresh'
class UsersController < ApplicationController
  before_action :set_user,             only: [:show, :publish, :background_refresh]
  before_action :set_authorizations,   only: [:show, :publish]
  before_action :feed_items_cache,     only: [:show]

  def show
  end

  def publish
    content = params[:content]
    @notice = "Posting: "
    if params[:provider].include?("twitter")
      @notice += "<br>to twitter"
      begin
        if params[:image]
          twitter_client.update_with_media(content, params[:image].tempfile)
          @result = "success"
        else
          twitter_client.update(content)
          @result = "success"
        end
      rescue Twitter::Error
      rescue Exception
      end
    end
    if params[:provider].include?("facebook")
      @notice += "<br>to facebook"
      begin
        if params[:image]
          facebook_client.put_picture(params[:image], {message: content})
          @result = "success"
        else
          facebook_client.put_wall_post(content)
          @result = "success"
        end
      rescue Koala::Facebook::APIError
      end
    end
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
      format.js
    end
  end

  def background_refresh
    BackgroundRefresh.new.async.perform(@user.id.to_s)
    render nothing: true
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def set_authorizations
      @twitter  = @user.authorizations.find_by(provider: 'twitter')
      @facebook = @user.authorizations.find_by(provider: 'facebook')
      # @flickr   = @user.authorizations.find_by(provider: 'flickr')
    end

    def twitter_client
      @twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key         = ENV["CONSUMER_KEY"]
        config.consumer_secret      = ENV["CONSUMER_SECRET"]
        config.access_token         = @twitter.token
        config.access_token_secret  = @twitter.secret
      end
    end

    def facebook_client
      @facebook_client ||= Koala::Facebook::API.new(@facebook.token)
    end

    # def flickr_client
    #   FlickRaw.api_key          = ENV["FLICKR_APP_KEY"]
    #   FlickRaw.shared_secret    = ENV["FLICKR_APP_SECRET"]
    #   @flickr_client                ||= FlickRaw::Flickr.new
    #   @flickr_client.access_token   ||= @flickr.token
    #   @flickr_client.access_secret  ||= @flickr.secret
    #   return @flickr_client
    # end

    def feed_items_cache
      Post.refresh_cache!(@user)
      @posts = @user.posts.all.sort_by(&:created_at).reverse
    end
end
