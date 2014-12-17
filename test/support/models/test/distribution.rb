require Rails.root + 'test/support/models/test/taxon_concept.rb'
require Rails.root + 'test/support/models/test/geo_entity.rb'

class Test::Distribution < ActiveRecord::Base
  belongs_to :taxon_concept, class_name: Test::TaxonConcept
  belongs_to :geo_entity, class_name: Test::GeoEntity
  has_many :distribution_references
  has_many :references, :through => :distribution_references
end

