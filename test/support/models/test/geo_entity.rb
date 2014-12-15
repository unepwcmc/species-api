require Rails.root + 'test/support/models/test/geo_entity_type.rb'

class Test::GeoEntity < ActiveRecord::Base
  belongs_to :geo_entity_type, class: Test::GeoEntityType
end
