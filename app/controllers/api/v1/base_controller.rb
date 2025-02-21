class Api::V1::BaseController < Api::BaseController
  before_action :set_language
  before_action :validate_params

  # Add these two lines to record analytics on api requests and errors on a controller
  after_action :track_this_request
  rescue_from StandardError, with: :track_this_error

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
        track_api_error("Unpermitted parameters (#{unpermitted_keys.join(', ')})", 422)
        return false
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

#    def cache_key
#      key = params.slice(*permitted_params).values.join('')
#      [controller_name, key].join('_')
#    end

    def cache_key
      cache_key_for(:index)
    end

    def cache_key_for(key, rec = nil)
      params_key = params.slice(*permitted_params).values.join('_')

      ts = rec&.cache_key_with_version || taxon_last_updated

      [controller_name, key, ts, params_key].join('__')
    end
end
