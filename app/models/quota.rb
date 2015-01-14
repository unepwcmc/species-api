class Quota < ActiveRecord::Base
  include Scope
  after_initialize :readonly!
  self.table_name = :api_cites_quotas_view
  self.primary_key = :id

  translates :geo_entity
  translates :unit

  belongs_to :taxon_concept
end
