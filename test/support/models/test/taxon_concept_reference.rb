class Test::TaxonConceptReference < ActiveRecord::Base
  belongs_to :reference, class_name: Test::Reference
  belongs_to :taxon_concept, class_name: Test::TaxonConcept
end
