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
      track_this_request
      return false
    end
  end

  # after_action method for recording API Metrics
  def track_this_request
    puts params
    ApiRequest.create(
      user_id: @user.try(:id),
      controller: params[:controller].split('/').last,
      action: params[:action],
      params: params.except(:controller, :action, :format),
      format: params[:format],
      ip: request.remote_ip,
      response_status: response.status
    )
  end

  # rescue_from method for recording API Metrics on 500 errors
  def track_this_error(exception)
    head status: 500 # Manually set this again because we're rescuing from rails magic
    ApiRequest.create(
      user_id: @user.try(:id),
      controller: params[:controller].split('/').last,
      action: params[:action],
      params: params.except(:controller, :action, :format),
      format: params[:format],
      ip: request.remote_ip,
      response_status: response.status,
      error_message: exception.to_s
    )
  end 
end
