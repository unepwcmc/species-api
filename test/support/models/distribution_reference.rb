class DistributionReference < ActiveRecord::Base
  self.table_name = :distribution_references
  self.primary_key = :id

  belongs_to :reference
  belongs_to :distribution, :touch => true
end
