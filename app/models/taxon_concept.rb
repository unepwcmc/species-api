class TaxonConcept < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_taxon_concepts_view
  self.primary_key = :id
  self.per_page = 500

  has_many :children, class_name: TaxonConcept, foreign_key: :parent_id
  has_many :distributions
  has_many :common_names
  has_many :cites_listings
  has_many :eu_listings
  has_many :eu_decisions
  has_many :taxon_references

  def cites_suspensions_including_global
    CitesSuspension.where(trade_restrictions_including_global_where_clause)
  end

  def cites_quotas_including_global
    Quota.where(trade_restrictions_including_global_where_clause)
  end

  private
  def trade_restrictions_including_global_where_clause
    if children_and_ancestors_ids.empty?
      ["taxon_concept_id = ?
      OR (
        taxon_concept_id IS NULL
        AND matching_taxon_concept_ids @> ARRAY[?]::INT[]
      )", self.id, self.id]
    else
      ["taxon_concept_id = ?
      OR (
        (taxon_concept_id IN (?) OR taxon_concept_id IS NULL)
        AND matching_taxon_concept_ids @> ARRAY[?]::INT[]
      )", self.id, children_and_ancestors_ids, self.id]
    end
  end

  def children_and_ancestors_ids
    (
      children.pluck(:id) +
      [
        higher_taxa['kingdom_id'],
        higher_taxa['phylum_id'],
        higher_taxa['order_id'],
        higher_taxa['class_id'],
        higher_taxa['family_id'],
        higher_taxa['subfamily_id'],
        higher_taxa['genus_id']
      ]
    ).compact
  end

end
