class CitesSuspension < ActiveRecord::Base
  include Scope
  after_initialize :readonly!
  self.table_name = :api_cites_suspensions_view
  self.primary_key = :id

  translates :geo_entity

  belongs_to :taxon_concept
end
