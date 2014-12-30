class Test::TradeRestriction < ActiveRecord::Base
  belongs_to :taxon_concept, class_name: Test::TaxonConcept
  belongs_to :geo_entity, class_name: Test::GeoEntity
end
