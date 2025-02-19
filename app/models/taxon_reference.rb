class TaxonReference < ApplicationRecord
  after_initialize :readonly!
  self.table_name = :api_taxon_references_view
  self.primary_key = :id
end
