class UsersController < ApplicationController
  before_action :set_user,             only: [:show, :publish]
  before_action :set_authorizations,   only: [:show, :publish]

  def show
    @feed_items ||= []
    create_feed('twitter')  if @twitter
    create_feed('facebook') if @facebook
    @feed_items = @feed_items.sort_by { |k| k[:created_at] }.reverse
    # @flickr_test = flickr_client.urls if @flickr
    # <%= @flickr_test.inspect %> hm flickr doesn't really provide a stream
  end

  def publish
    content = params[:content]
    if params[:provider].include?("twitter")
      if params[:image]
        twitter_client.update_with_media(content, params[:image])
      else
        twitter_client.update(content)
      end
    end
    if params[:provider].include?("facebook")
      if params[:image]
        facebook_client.put_picture(params[:image], {message: content})
      else
        facebook_client.put_wall_post(content)
      end
    end
    redirect_to user_path(@user)
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

    def create_feed(provider)
      if provider == 'twitter'
        tweets = twitter_client.home_timeline
        tweets.each do |tweet|
          @feed_items << {
            user_screen_name:   tweet.user.name,
            user_name:          tweet.user.screen_name,
            user_image_url:     tweet.user.profile_image_url,
            user_url:           "https://www.twitter.com/#{tweet.user.screen_name}",
            user_image_url:     tweet.user.profile_image_url,
            text:               tweet.text,
            url:                "https://www.twitter.com/#{tweet.user.screen_name}/statuses/#{tweet.id}",
            created_at:         tweet.created_at,
            provider:           "twitter"
            }
        end
      end
      if provider == 'facebook'
        @facebook_feed = facebook_client.get_connections('me', 'home')
        @facebook_feed.each do |post|
          @feed_items << {
            user_screen_name:   post['from']['name'],
            user_url:           "https://www.facebook.com/#{post['from']['id']}/",
            user_image_url:     "http://graph.facebook.com/#{post['from']['id']}/picture",
            text:               post['message'],
            picture_url:        post['picture'],
            link:               post['link'],
            name:               post['name'],
            link_caption:       post['caption'],
            story:              post['story'],
            url:                "https://www.facebook.com/#{post['id']}/",
            created_at:         DateTime.parse(post['created_time']),
            provider:           "facebook"
          }
        end
      end


    end
end
