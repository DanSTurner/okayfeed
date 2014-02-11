Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter,  ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], scope: 'read_stream, publish_actions', display: 'popup'
  provider :flickr,   ENV['FLICKR_APP_KEY'], ENV['FLICKR_APP_SECRET'], scope: 'read'
end