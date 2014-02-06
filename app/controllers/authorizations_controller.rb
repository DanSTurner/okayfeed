class AuthorizationsController < ApplicationController
  before_action :set_user, only: [:create, :destroy]

  def create
    # raise request.inspect
    auth = request.env["omniauth.auth"]
    @user.authorizations.create(provider: auth["provider"],
                                    uid:      auth["uid"],
                                    token:    auth["credentials"]["token"],
                                    secret:   auth["credentials"]["secret"],
                                    name:     auth["info"]["name"])
    redirect_to edit_user_registration_path(@user)
  end

  def destroy
    @user.authorization.destroy
    redirect_to
  end

  private
    def set_user
      @user = User.find(current_user.id)
    end
end
