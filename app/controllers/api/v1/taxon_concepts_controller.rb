class Api::V1::TaxonConceptsController < ApplicationController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
    name 'Taxon Concepts'
  end

  api :GET, '/', "Lists taxon concepts"
  param :page, Integer, :desc => "Page Number", :required => false
  example <<-EOS
    'taxon_concepts': [
      {
        'id': 1,
        'scientific_name': 'Loxodonta africana',
        'author_year': '(Blumenbach, 1797)',
        'rank': 'SPECIES'
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
