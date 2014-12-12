class GeoEntity < ActiveRecord::Base
  self.table_name = :geo_entities
  self.primary_key = :id

  has_many :geo_relationships
  has_many :distributions
  # has_many :designation_geo_entities, :dependent => :destroy
  # has_many :designations, :through => :designation_geo_entities
  # has_many :quotas
  # has_many :eu_opinions
  # has_many :eu_suspensions
  # has_many :exported_shipments, :class_name => 'Trade::Shipment',
  #   :foreign_key => :exporter_id
  # has_many :imported_shipments, :class_name => 'Trade::Shipment',
  #   :foreign_key => :importer_id
  # has_many :originated_shipments, :class_name => 'Trade::Shipment',
  #   :foreign_key => :country_of_origin_id
end
