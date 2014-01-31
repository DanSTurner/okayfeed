class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def twitter_client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key         = ENV["CONSUMER_KEY"]
      config.consumer_secret      = ENV["CONSUMER_SECRET"]
      # config.access_token         = ENV["ACCESS_TOKEN"]
      # config.access_token_secret  = ENV["ACCESS_TOKEN_SECRET"]
    end
  end

  protected
    def devise_parameter_sanitizer
      if resource_class == User
        User::ParameterSanitizer.new(User, :user, params)
      else
        super
      end
    end
end
