require Rails.root + 'test/support/models/test/language.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'

class Test::CommonName < ApplicationRecord
  belongs_to :language, class_name: 'Test::Language', optional: true
  belongs_to :taxon_concept, class_name: 'Test::TaxonConcept', optional: true
  belongs_to :created_by, foreign_key: :created_by_id, class_name: 'User', optional: true
  belongs_to :updated_by, foreign_key: :updated_by, class_name: 'User', optional: true

  after_save Test::TaxonConceptTouch.new
end
