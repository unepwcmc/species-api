class Api::BaseController < ApplicationController
  skip_before_action :authenticate_user!
  respond_to :xml, :json
  before_action :authenticate, except: [:test_exception_notifier]
  before_action :set_content_type_if_xml

  # this end-point to be used to test exception notifier
  def test_exception_notifier
    raise 'This is a test. This is only a test.'
  end

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

  def set_content_type_if_xml
    # rabl does not set the content type properly for XML
    if params[:format] && params[:format].downcase.strip.to_sym == :xml
      response.headers['Content-Type'] = 'application/xml; charset=utf-8'
    end
  end

  # after_action method for recording API Metrics
  def track_this_request
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
    if Rails.env.production? || Rails.env.staging?
      ExceptionNotifier.notify_exception(exception,
        :env => request.env, :data => {:message => "Something went wrong"})
    end

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
