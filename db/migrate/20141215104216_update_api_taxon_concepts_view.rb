class UpdateApiTaxonConceptsView < ActiveRecord::Migration
  def change
    drop_view :api_taxon_concepts_view, if_exists: true
    create_view :api_taxon_concepts_view, view_sql('20141215104216', 'api_taxon_concepts_view')
  end
end
