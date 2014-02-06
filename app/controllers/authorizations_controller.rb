class AuthorizationsController < ApplicationController
  before_action :set_user, only: [:create, :destroy]

  def create
    auth = request.env["omniauth.auth"]
    authorization = @user.authorizations.build
    authorization.update_attributes(provider: auth["provider"],
                                    uid:      auth["uid"],
                                    token:    auth["credentials"]["token"],
                                    secret:   auth["credentials"]["secret"],
                                    name:     auth["info"]["name"])
    authorization.save
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
