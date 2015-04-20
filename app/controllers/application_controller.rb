class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :authenticate_is_api_or_admin
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up).push(:name, :terms_and_conditions, :geo_entity_id, :organisation, :is_cites_authority)
      devise_parameter_sanitizer.for(:account_update).push(:name, :geo_entity_id, :organisation, :is_cites_authority)
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
