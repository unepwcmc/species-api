class CitesSuspension < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_cites_suspensions_view
  self.primary_key = :id

  belongs_to :taxon_concept
end
