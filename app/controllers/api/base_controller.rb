class Api::BaseController < ApplicationController
  skip_before_action :authenticate_user!
  respond_to :xml, :json
  before_action :authenticate

  private

  def authenticate
    token = request.headers['X-Authentication-Token']
    @user = User.where(authentication_token: token).first if token
    if @user.nil? || @user.is_contributor?
      head status: :unauthorized
      return false
    end
  end

end
