class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :authenticate_is_api_or_admin
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

    def configure_permitted_parameters
      extra_parameters = [:name, :is_cites_authority, :organisation, :geo_entity_id]

      devise_parameter_sanitizer.permit(:sign_up, keys: [ *extra_parameters, :terms_and_conditions ])
      devise_parameter_sanitizer.permit(:account_update, keys: extra_parameters)
    end

    def after_sign_in_path_for(resource)
      dashboard_path
    end

    def authenticate_is_api_or_admin
      unless (params[:controller] == 'registrations') || (params[:controller] == 'devise/sessions')
        if current_user && current_user.is_contributor?
          sign_out current_user
          redirect_to new_user_registration_path, notice: "You do not have permission to access the API, please sign up for an API account"
        end
      end
    end
end
