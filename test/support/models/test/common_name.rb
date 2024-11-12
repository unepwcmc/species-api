require Rails.root + 'test/support/models/test/language.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'

class Test::CommonName < ApplicationRecord
  belongs_to :language, class_name: 'Test::Language'
  belongs_to :taxon_concept, class_name: 'Test::TaxonConcept'
  after_save Test::TaxonConceptTouch.new
end
