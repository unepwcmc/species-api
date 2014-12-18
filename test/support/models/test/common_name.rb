require Rails.root + 'test/support/models/test/language.rb'
class Test::CommonName < ActiveRecord::Base
  belongs_to :language, class_name: Test::Language
  belongs_to :taxon_concept, class_name: Test::TaxonConcept
end
