class Api::V1::TaxonConceptsController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/taxon_concepts'
    name 'Taxon Concepts'
  end

  api :GET, '/', 'Lists taxon concepts'
  param :page, Integer, desc: 'Page Number', required: false
  param :updated_since, Time, desc: 'Return taxa updated since', required: false
  example <<-EOS
    'taxon_concepts': [
      {
        'id': 4521,
        'scientific_name': 'Loxodonta africana',
        'author_year': '(Blumenbach, 1797)',
        'rank': 'SPECIES',
        'name_status': 'A',
        'higher_taxa': {
          'genus': 'Loxodonta',
          'family': 'Elephantidae',
          'order': 'Proboscidea',
          'class': 'Mammalia',
          'phylum': 'Chordata'
        },
        'synonyms': [
          {
            id: 37069,
            scientific_name: 'Loxodonta cyclotis',
            author_year: '(Matschie, 1900)'
          }
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
    @taxon_concepts = TaxonConcept.
      where(
        rank_name: 'SPECIES',
        taxonomy_is_cites_eu: true,
        name_status: 'A',
        full_name: 'Loxodonta africana'
      ).order('full_name').limit(100) # TODO paginate
    render 'api/v1/taxon_concepts/index'
  end
end
