class CitesListing < ActiveRecord::Base
  include Scope
  after_initialize :readonly!
  self.table_name = :api_cites_listing_changes_view
  self.primary_key = :id

  translates :party, :annotation, :hash_annotation

  belongs_to :taxon_concept
end
