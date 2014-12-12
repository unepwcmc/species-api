class Reference < ActiveRecord::Base
  self.table_name = :references
  self.primary_key = :id

  #has_many :taxon_concept_references
  has_many :distribution_references
end
