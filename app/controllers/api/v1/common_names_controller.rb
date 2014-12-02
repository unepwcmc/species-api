class Api::V1::CommonNamesController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
  end

  api :GET, '/:id/common_names', 'Lists common names for a given taxon concept'
  param :id, Integer, desc: 'Taxon Concept ID', required: true
  example <<-EOS
    'common_names': [
      {
        'name': 'African Elephant',
        'lng': 'EN'
      },
      {
        'name': 'Afrikanischer Elefant',
        'lng': 'DE'
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
