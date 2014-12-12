class Distribution < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_distributions_view
  self.primary_key = :id

  belongs_to :geo_entity
  belongs_to :taxon_concept
  has_many :distribution_references, :dependent => :destroy
  has_many :references, :through => :distribution_references
end
