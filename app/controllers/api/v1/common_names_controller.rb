class Api::V1::CommonNamesController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
  end

  api :GET, '/:taxon_concept_id/common_names', 'Lists common names for a given taxon concept'
  param :taxon_concept_id, String, desc: 'Taxon Concept ID', required: true
  param :language, String, desc: 'Filter languages returned for common names. Value should be a single country code or a comma separated array of country codes (e.g. language=EN,PL,IT). Defaults to showing all available languages if no language parameter is specified', required: false

  example <<-EOS
    'common_names': [
      {
        'name': 'African Elephant',
        'language': 'EN'
      },
      {
        'name': 'Afrikanischer Elefant',
        'language': 'DE'
      }
    ]
  EOS

  example <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <common-names type="array">
      <common-name>
        <name>Common Goldeneye</name>
        <language>EN</language>
      </common-name>
    </common-names>
  EOS

  def index
    languages = params[:language].split(',').map! { |lang| lang.upcase } unless params[:language].nil?

    @common_names = TaxonConcept.find(params[:taxon_concept_id]).common_names
    @common_names = @common_names.where(iso_code1: languages) unless languages.nil?
  end
end
