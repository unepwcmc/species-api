require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/taxon_concept_touch.rb'
require Rails.root + 'test/support/models/test/common_name.rb'
class Test::TaxonCommon < ActiveRecord::Base
  belongs_to :taxon_concept, class_name: Test::TaxonConcept
  belongs_to :common_name, class_name: Test::CommonName
  after_save Test::TaxonConceptTouch.new
end
