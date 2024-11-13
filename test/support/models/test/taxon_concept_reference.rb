require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'

class Test::TaxonConceptReference < ApplicationRecord
  belongs_to :reference, class_name: 'Test::Reference'
  belongs_to :taxon_concept, class_name: 'Test::TaxonConcept'

  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'User', optional: true
  belongs_to :updated_by, foreign_key: :updated_by, class_name: 'User', optional: true

  after_save Test::TaxonConceptTouch.new
end
