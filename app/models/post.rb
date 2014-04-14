class Post < ActiveRecord::Base
  belongs_to :user

  def self.refresh_cache!(user)
    self.set_user(user)
    self.set_authorizations
    if self.cache_stale?
      @user.posts.delete_all
      if @twitter
        tweets = self.twitter_client.home_timeline
        tweets.each do |tweet|
          @post = @user.posts.build(
            user_screen_name:   tweet.user.name,
            user_name:          tweet.user.screen_name,
            user_image_url:     tweet.user.profile_image_url.to_s,
            user_url:           "https://www.twitter.com/#{tweet.user.screen_name}",
            text:               tweet.text,
            url:                "https://www.twitter.com/#{tweet.user.screen_name}/statuses/#{tweet.id}",
            created_at:         tweet.created_at,
            provider:           "twitter"
            )
          @post.save
        end
      end
      if @facebook
        facebook_feed = self.facebook_client.get_connections('me', 'home')
        facebook_feed.each do |post|
          @post = @user.posts.build(
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
            )
          @post.save
        end
      end
      if @flickr
        flickr_feed = self.flickr_client.photos.getContactsPhotos(count: 30, include_self: 'include_self', extras: 'date_upload')
        flickr_feed.each do |post|
          @post = @user.posts.build(
            user_screen_name:   post['username'],
            user_url:           "http://www.flickr.com/photos/#{post['owner']}/",
            user_image_url:     "http://flickr.com/buddyicons/#{post['owner']}.jpg",
            text:               post['title'],
            picture_url:        "http://farm#{post['farm']}.static.flickr.com/#{post['server']}/#{post['id']}_#{post['secret']}_n.jpg",
            url:                "http://www.flickr.com/photos/#{post['owner']}/#{post['id']}",
            created_at:         DateTime.parse(Time.at(post['dateupload'].to_i).to_datetime.to_s),
            provider:           "flickr"
            )
          @post.save
        end
      end
      @user.update_attribute(:feed_updated_at, Time.now)
    end
  end

  def self.cache_refreshed?(user)
    self.set_user(user)
    (Time.now - @user.feed_updated_at) / 60 < 1 ? true : false
  end

  def self.cleanse!(user, removed_provider)
    self.set_user(user)
    @user.posts.where(provider: removed_provider).each do |post|
      post.destroy!
    end
  end

  private
    def self.set_user(user)
      @user = user
    end

    def self.set_authorizations
      @twitter  = @user.authorizations.find_by(provider: 'twitter')
      @facebook = @user.authorizations.find_by(provider: 'facebook')
      @flickr   = @user.authorizations.find_by(provider: 'flickr')
    end

    def self.twitter_client
      @twitter_client ||= Twitter::REST::Client.new do |config|
        config.consumer_key         = ENV["CONSUMER_KEY"]
        config.consumer_secret      = ENV["CONSUMER_SECRET"]
        config.access_token         = @twitter.token
        config.access_token_secret  = @twitter.secret
      end
    end

    def self.facebook_client
      @facebook_client ||= Koala::Facebook::API.new(@facebook.token)
    end

    def self.flickr_client
      FlickRaw.api_key          = ENV["FLICKR_APP_KEY"]
      FlickRaw.shared_secret    = ENV["FLICKR_APP_SECRET"]
      FlickRaw.secure           = false
      @flickr_client                ||= FlickRaw::Flickr.new
      @flickr_client.access_token   ||= @flickr.token
      @flickr_client.access_secret  ||= @flickr.secret
      return @flickr_client
    end

    def self.cache_stale?
      if @user.feed_updated_at
        t = @user.feed_updated_at
        (Time.now - t) / 60 > 1 ? true : false
      else
        return true
      end
    end
end
