require Rails.root + 'test/support/models/test/geo_entity_type.rb'

class Test::GeoEntity < ApplicationRecord
  belongs_to :geo_entity_type, class_name: 'Test::GeoEntityType'
end
