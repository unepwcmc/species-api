require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'

class Test::ListingChange < ApplicationRecord
  belongs_to :annotation, class_name: 'Test::Annotation', optional: true
  belongs_to :hash_annotation, class_name: 'Test::Annotation', optional: true
  belongs_to :taxon_concept, class_name: 'Test::TaxonConcept', optional: true
  belongs_to :change_type, class_name: 'Test::ChangeType', optional: true
  belongs_to :species_listing, class_name: 'Test::SpeciesListing', optional: true
  belongs_to :event, class_name: 'Test::Event', foreign_key: :event_id, optional: true

  belongs_to :original, class_name: 'Test::ListingChange', optional: true
  belongs_to :parent, class_name: 'Test::ListingChange', optional: true
  # belongs_to :inclusion, class_name: 'Test::TaxonConcept', foreign_key: 'inclusion_taxon_concept_id', optional: true
  belongs_to :inclusion_taxon_concept, class_name: 'Test::TaxonConcept', foreign_key: 'inclusion_taxon_concept_id', optional: true

  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'User', optional: true
  belongs_to :updated_by, foreign_key: :updated_by, class_name: 'User', optional: true

  has_many :exclusions, class_name: 'Test::ListingChange', foreign_key: 'parent_id', dependent: :destroy
  has_many :listing_change_copies, foreign_key: :original_id, class_name: 'Test::ListingChange', dependent: :nullify

  after_save Test::TaxonConceptTouch.new
end

class Test::ListingChange::Annotation < Test::ListingChange
end