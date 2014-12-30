class Test::EuDecision < ActiveRecord::Base
  belongs_to :eu_decision_type
  belongs_to :taxon_concept, class_name: Test::TaxonConcept
  belongs_to :geo_entity, class_name: Test::GeoEntity
  belongs_to :source, class_name: Test::Source, foreign_key: :source_id
  belongs_to :term, class_name: Test::Term, foreign_key: :term_id
  belongs_to :start_event, class_name: Test::EuSuspensionRegulation, foreign_key: :start_event_id
end
