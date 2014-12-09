class Api::V1::ReferencesController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
  end

  api :GET, '/:id/references', 'Lists references for a given taxon concept'
  param :id, Integer, desc: 'Taxon Concept ID', required: true
  example <<-EOS
    'references': [
      {
        'citation': 'Barnes, R. F., Agnagna, M., Alers, M. P. T.',
        'is_standard' : false
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
  end
end
