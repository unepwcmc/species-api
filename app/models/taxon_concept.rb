# == Schema Information
#
# Table name: api_taxon_concepts_view
#
#  id                   :integer          primary key
#  parent_id            :integer
#  name                 :string(255)
#  taxonomy_is_cites_eu :boolean
#  full_name            :string(255)
#  author_year          :string(255)
#  name_status          :text
#  rank                 :string(255)
#  taxonomic_position   :string
#  higher_taxa          :json
#  synonyms             :json
#  accepted_names       :json
#  created_at           :datetime
#  updated_at           :datetime
#

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

  def is_accepted_name?
    name_status == 'A'
  end

  def is_synonym?
    name_status == 'S'
  end

  def common_names_with_iso_code(languages = nil)
    result = common_names.select([
      :iso_code1,
      :name
    ]).where("iso_code1 IS NOT NULL")
    if languages && !languages.empty?
      result = result.where(iso_code1: languages)
    end
    result
  end

  def current_cites_additions
    cites_listings.select([
      :id,
      :effective_at,
      :species_listing_name,
      :party_en,
      :party_es,
      :party_fr,
      :annotation_en,
      :annotation_es,
      :annotation_fr,
      :hash_annotation_en,
      :hash_annotation_es,
      :hash_annotation_fr
    ]).where(is_current: true, change_type_name: 'ADDITION')
  end

  def current_eu_listings
    eu_listings.select([
      :id,
      :effective_at,
      :eu_regulation,
      :species_listing_name,
      :party_en,
      :party_es,
      :party_fr,
      :annotation_en,
      :annotation_es,
      :annotation_fr,
      :hash_annotation_en,
      :hash_annotation_es,
      :hash_annotation_fr
    ]).where(is_current: true, change_type_name: 'ADDITION')
  end

  def cites_suspensions_including_global
    CitesSuspension.where(
      [
        "taxon_concept_id IN (:self_and_children)
        OR (
          NOT applies_to_import
          AND (taxon_concept_id IN (:ancestors) OR taxon_concept_id IS NULL)
          AND geo_entity_id IN
            (SELECT geo_entity_id FROM distributions WHERE distributions.taxon_concept_id = :taxon_concept_id)
        )
        OR (
          (applies_to_import OR geo_entity_id IS NULL)
          AND taxon_concept_id IN (:ancestors)
        )",
        self_and_children: self_and_children_ids, ancestors: ancestors_ids, taxon_concept_id: self.id
      ]
    )
  end

  def cites_quotas_including_global
    Quota.where(
      [
        "taxon_concept_id IN (:self_and_children)
        OR (
          (taxon_concept_id IN (:ancestors) OR taxon_concept_id IS NULL)
          AND geo_entity_id IN
            (SELECT geo_entity_id FROM distributions WHERE distributions.taxon_concept_id = :taxon_concept_id)
        )",
        self_and_children: self_and_children_ids, ancestors: ancestors_ids, taxon_concept_id: self.id
      ]
    )
  end

  private

  def self_and_children_ids
    [self.id] + children.pluck(:id)
  end

  def ancestors_ids
    [
      kingdom_id,
      phylum_id,
      class_id,
      order_id,
      family_id,
      subfamily_id,
      genus_id
    ].compact
  end

end
