require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/geo_entity.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'

class Test::Distribution < ApplicationRecord
  belongs_to :taxon_concept, class_name: 'Test::TaxonConcept'
  belongs_to :geo_entity, class_name: 'Test::GeoEntity'
  has_many :distribution_references
  has_many :references, :through => :distribution_references
  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'User', optional: true
  belongs_to :updated_by, foreign_key: :updated_by, class_name: 'User', optional: true

  after_save Test::TaxonConceptTouch.new
end

