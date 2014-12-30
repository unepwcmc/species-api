class Distribution < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_distributions_view
  self.primary_key = :id

  translates :name

  belongs_to :taxon_concept
end
