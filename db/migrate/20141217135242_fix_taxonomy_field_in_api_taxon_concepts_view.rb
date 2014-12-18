class FixTaxonomyFieldInApiTaxonConceptsView < ActiveRecord::Migration
  def change
    drop_view :api_taxon_concepts_view, if_exists: true
    create_view :api_taxon_concepts_view, view_sql('20141217135242', 'api_taxon_concepts_view')
  end
end
