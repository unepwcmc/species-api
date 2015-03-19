class Api::V1::BaseController < Api::BaseController
  before_action :set_language
  before_action :permit_params

  # Add these two lines to record analytics on api requests and errors on a controller
  after_action :track_this_request
  rescue_from StandardError, with: :track_this_error

  private
  
    def set_language
      language = params[:language].try(:downcase).try(:strip).try(:to_sym) ||
        :en
      I18n.locale = if [:en, :es, :fr].include?(language)
        language
      else
        I18n.default_locale
      end
    end

    def set_legislation_scope
      @legislation_scope = params[:scope].try(:downcase).try(:strip).try(:to_sym) ||
        :current
      unless [:all, :current, :historic].include?(@legislation_scope)
        @legislation_scope = :current
      end
    end

    def permit_params
      permitted = permit_params_child
      never_unpermitted = ActionController::Parameters::NEVER_UNPERMITTED_PARAMS
      unpermitted_keys = params.keys - permitted.keys - never_unpermitted
      if unpermitted_keys.any?
        @message = "Unpermitted parameters"
        create_api_request(@message, 422)
        render 'api/error', status: 422
      end
    end

    def permit_params_child; end
end
