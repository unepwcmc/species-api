class Api::V1::BaseController < Api::BaseController
  before_action :set_language
  before_action :validate_params

  # Add these two lines to record analytics on api requests and errors on a controller
  after_action :track_this_request
  rescue_from StandardError, with: :track_this_error

  private

    def set_language
      language = params[:language].try(:downcase).try(:strip) ||
        'en'
      I18n.locale = if ['en', 'es', 'fr'].include?(language)
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

    def validate_params
      always_permitted = ActionController::Parameters.always_permitted_parameters
      unpermitted_keys = params.keys - permitted_params.map(&:to_s) - always_permitted
      if unpermitted_keys.any?
        track_api_error("Unpermitted parameters (#{unpermitted_keys.join(', ')})", 422)
        return false
      end
    end

    def cache_key
      key = params.slice(*permitted_params).values.join('')
      [controller_name, key].join('_')
    end
end
