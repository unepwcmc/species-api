class EuListing < ActiveRecord::Base
  include Scope
  after_initialize :readonly!
  self.table_name = :api_eu_listing_changes_view
  self.primary_key = :id

  translates :party, :annotation, :hash_annotation

  belongs_to :taxon_concept
end