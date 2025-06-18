
class Api::V1::BaseController < Api::BaseController
  before_action :set_language
  before_action :validate_params

  # Add these two lines to record analytics on api requests and errors on a controller
  after_action :track_this_request
  rescue_from StandardError, with: :track_unhandled_error
  rescue_from Api::ValidationError, with: :track_validation_error
  rescue_from Api::PaginationError, with: :track_validation_error
  rescue_from ActiveRecord::RecordNotFound, with: :track_not_found_error
  rescue_from ActionController::RoutingError, with: :track_not_found_error

  protected
    def permitted_params
      NoMethodError
    end
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
        raise Api::ValidationError, "Unpermitted parameters (#{unpermitted_keys.join(', ')})"
      end
    end

    # Returns the timestamp at which the last time a taxon was updated
    # (or deleted).
    def taxon_last_updated
      # if we are not caching anything, don't even bother querying the db
      return DateTime.now.to_fs(:number) if
        :null_store == Rails.configuration.cache_store

      Rails.cache.fetch(:taxon_last_updated, expires_in: 1.hour) do
        # TaxonConcept.maximum(:updated_at).to_fs(:number)
        # but this is a slow view.
        #
        # Much faster to decompose:
        [
          # Find last updated date of any taxon
          TaxonConcept.from('taxon_concepts').where(
            'taxon_concepts.name_status': ['A', 'S']
          ).maximum(:updated_at),
          TaxonConcept.from('taxon_concepts').where(
            'taxon_concepts.name_status': ['A', 'S']
          ).maximum('taxon_concepts.dependents_updated_at'),
          # Find the time last Taxon was deleted
          TaxonConcept.from('taxon_concept_versions').where(
            'taxon_concept_versions.name_status': ['A', 'S'],
            'taxon_concept_versions.event': 'destroy',
          ).maximum(:created_at)
        ].max&.to_fs(:number)
      end || DateTime.now.to_fs(:number)
    end

    def cache_key
      cache_key_for(:index)
    end

    def cache_key_for(prefix_key, rec = nil)
      prefix_key_string =
        if prefix_key.is_a? Array
          prefix_key.map(&:to_s).join('_')
        else
          prefix_key.to_s
        end

      params_key_string = params.slice(*permitted_params).values.map(&:to_s).join('_')

      version_string = rec&.cache_key_with_version || taxon_last_updated

      [
        controller_name,
        prefix_key_string,
        params_key_string,
        version_string
      ].join('/')
    end
end
