require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'
require Rails.root + 'test/support/models/test/geo_entity.rb'
class Test::TradeRestriction < ActiveRecord::Base
  belongs_to :taxon_concept, class_name: Test::TaxonConcept
  belongs_to :geo_entity, class_name: Test::GeoEntity
  after_save Test::TaxonConceptTouch.new
end
