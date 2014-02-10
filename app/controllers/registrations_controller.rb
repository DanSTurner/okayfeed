class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :authenticate_scope!, only: [:edit]
  before_action :set_authorizations,          only: [:edit]

  def edit
    render :edit
  end

  protected
    def set_authorizations
      @twitter = @user.authorizations.find_by(provider: 'twitter')
      @facebook = @user.authorizations.find_by(provider: 'facebook')
    end

end