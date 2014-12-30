class Test::ListingChange < ActiveRecord::Base
  belongs_to :taxon_concept, class_name: Test::TaxonConcept
  belongs_to :change_type, class_name: Test::ChangeType
  belongs_to :species_listing, class_name: Test::SpeciesListing
  belongs_to :event, class_name: Test::EuRegulation, foreign_key: :event_id
end
