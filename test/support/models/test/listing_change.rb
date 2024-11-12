require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'

class Test::ListingChange < ApplicationRecord
  belongs_to :taxon_concept, class_name: 'Test::TaxonConcept'
  belongs_to :change_type, class_name: 'Test::ChangeType'
  belongs_to :species_listing, class_name: 'Test::SpeciesListing'
  belongs_to :event, class_name: 'Test::EuRegulation', foreign_key: :event_id
  after_save Test::TaxonConceptTouch.new
end
