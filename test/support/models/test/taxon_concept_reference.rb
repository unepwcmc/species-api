require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'

class Test::TaxonConceptReference < ApplicationRecord
  belongs_to :reference, class_name: 'Test::Reference'
  belongs_to :taxon_concept, class_name: 'Test::TaxonConcept'
  after_save Test::TaxonConceptTouch.new
end
