class TaxonConcept < ActiveRecord::Base
  self.table_name = :api_taxon_concepts_view
  self.primary_key = :id
  self.per_page = 100
end
