class Api::V1::NamesController < ApplicationController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
  end

  api :GET, '/:id/names', "Lists synonyms and common names for a given taxon concept"
  param :id, Integer, :desc => "Taxon Concept ID", :required => true
  example <<-EOS
    'synonyms': [
      {
        'id': 1,
        'scientific_name': 'Loxodonta africana'
      }
    ],
    'common_names': [
      {
        'id': 1,
        'scientific_name': 'Loxodonta africana'
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
