require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'
require Rails.root + 'test/support/models/test/geo_entity.rb'

class Test::TradeRestriction < ApplicationRecord
  belongs_to :taxon_concept, class_name: 'Test::TaxonConcept', optional: true
  belongs_to :geo_entity, class_name: 'Test::GeoEntity', optional: true
  belongs_to :unit, class_name: 'Test::Unit', optional: true

  belongs_to :start_notification, class_name: 'Test::CitesSuspensionNotification', optional: true
  belongs_to :end_notification, class_name: 'Test::CitesSuspensionNotification', optional: true

  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'User', optional: true
  belongs_to :updated_by, foreign_key: :updated_by, class_name: 'User', optional: true

  after_save Test::TaxonConceptTouch.new
end
