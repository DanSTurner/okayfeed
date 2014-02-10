Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV["CONSUMER_KEY"], ENV["CONSUMER_SECRET"]
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], scope: 'read_stream', display: 'popup'
  # provider :linked_in, 'CONSUMER_KEY', 'CONSUMER_SECRET'
end