class Api::V1::DistributionsController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
  end

  api :GET, '/:id/distributions', 'Lists distributions for a given taxon concept'
  param :taxon_concept_id, String, desc: 'Taxon Concept ID', required: true
  param :language, String, desc: 'Select language for the names of distributions. Select en, fr, or es. Defaults to en if no language parameter is specified', required: false

  example <<-EOS
    'distributions': [
      {
        'name' : 'Burundi',
        'iso_code2': '...',
        'type': 'COUNTRY',
        'tags' : ['extinct','uncertain'],
        'references' : [
          citation1, citation2
        ]
      }
    ]
  EOS

  example <<-EOS
    <cites_legislation>
      <taxon_concept_id>1</taxon_concept_id>
      <is_current>true</is_current>
    </cites_legislation>
  EOS

  def index
    @distributions = TaxonConcept.find(params[:taxon_concept_id]).distributions
    @language = params[:language]
  end
end
