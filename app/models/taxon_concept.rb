class TaxonConcept < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_taxon_concepts_view
  self.primary_key = :id
  self.per_page = 500

  has_many :distributions
  has_many :common_names

  def cites_suspensions_including_global
    CitesSuspension.where(
      'taxon_concept_id IS NULL OR taxon_concept_id = ?', self.id
    )
  end
end
