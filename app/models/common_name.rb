class CommonName < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_common_names_view
  self.primary_key = :id

  belongs_to :taxon_concept
end