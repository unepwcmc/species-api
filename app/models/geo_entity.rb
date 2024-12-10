class GeoEntity < ApplicationRecord
  belongs_to :geo_entity_type
  translates :name
end
