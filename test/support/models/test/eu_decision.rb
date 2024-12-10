require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'

class Test::EuDecision < ApplicationRecord
  belongs_to :eu_decision_type
  belongs_to :taxon_concept, class_name: 'Test::TaxonConcept', optional: true
  belongs_to :geo_entity, class_name: 'Test::GeoEntity', optional: true
  belongs_to :source, class_name: 'Test::Source', foreign_key: :source_id, optional: true
  belongs_to :term, class_name: 'Test::Term', foreign_key: :term_id, optional: true
  belongs_to :srg_history, class_name: 'Test::SrgHistory', optional: true
  belongs_to :start_event, class_name: 'Test::EuSuspensionRegulation', foreign_key: :start_event_id, optional: true
  belongs_to :end_event, class_name: 'Test::EuSuspensionRegulation', foreign_key: :end_event_id, optional: true
  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'User', optional: true
  belongs_to :updated_by, foreign_key: :updated_by, class_name: 'User', optional: true
  after_save Test::TaxonConceptTouch.new
end
