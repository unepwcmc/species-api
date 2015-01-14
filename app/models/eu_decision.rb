class EuDecision < ActiveRecord::Base
  include Scope
  after_initialize :readonly!
  self.table_name = :api_eu_decisions_view
  self.primary_key = :id

  translates :geo_entity, :source, :term

  belongs_to :taxon_concept

end