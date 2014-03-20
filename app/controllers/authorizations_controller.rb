class AuthorizationsController < ApplicationController
  before_action :set_user, only: [:create, :destroy]

  def create
    auth = request.env["omniauth.auth"]
    @user.authorizations.create(provider:           auth["provider"],
                                uid:                auth["uid"],
                                token:              auth["credentials"]["token"],
                                secret:             auth["credentials"]["secret"],
                                name:               auth["info"]["name"])
    @user.update_attribute(:feed_updated_at, Time.now - 7.minutes)
    redirect_to user_path(@user)
  end

  def destroy
    provider = @user.authorizations.find_by(provider: params[:provider])
    provider.destroy
    redirect_to user_path(@user)
  end

  private
    def set_user
      @user = User.find(current_user.id)
    end
end
