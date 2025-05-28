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

class TaxonConcept < ApplicationRecord
  after_initialize :readonly!
  self.table_name = :api_taxon_concepts_view
  self.primary_key = :id
  self.per_page = 500

  attr_accessor :common_names_list, :cites_listings_list

  has_many :children, class_name: 'TaxonConcept', foreign_key: :parent_id
  has_many :distributions
  has_many :common_names
  has_many :cites_listings
  has_many :eu_listings
  has_many :eu_decisions
  has_many :taxon_references

  has_many :current_cites_additions,
    -> do
      where(
        is_current: true,
        change_type_name: 'ADDITION'
      ).order(
        'effective_at DESC, species_listing_name ASC'
      )
    end,
    foreign_key: :taxon_concept_id,
    class_name: 'CitesListing'

  has_many :current_eu_additions,
    -> do
      where(
        is_current: true,
        change_type_name: 'ADDITION'
      ).order(
        'effective_at DESC, species_listing_name ASC'
      )
    end,
    foreign_key: :taxon_concept_id,
    class_name: 'EuListing'

  # This needs to be a relationship rather than a function so it can be
  # efficiently retrieved from the database in bulk for downloads.
  has_many :cites_suspensions_including_global,
    -> do
      select(
        'api_cites_suspensions_view.*'
      ).from(
        TaxonConcept.from(
          TaxonConcept.cites_linking_taxon_concept_sql
        ), :linking_taxon_concept
      ).joins(
        <<-SQL.squish
          JOIN api_cites_suspensions_view api_cites_suspensions_view
            ON (
            (
              api_cites_suspensions_view.taxon_concept_id = ANY(
                linking_taxon_concept.descendant_taxon_concept_ids
              )
            ) OR (
              NOT applies_to_import AND (
                api_cites_suspensions_view.taxon_concept_id = ANY(
                  linking_taxon_concept.ancestor_taxon_concept_ids
                )
                OR
                api_cites_suspensions_view.taxon_concept_id IS NULL
              ) AND api_cites_suspensions_view.geo_entity_id = ANY(
                  linking_taxon_concept.geo_entity_ids
                )
            ) OR (
              (
                applies_to_import OR api_cites_suspensions_view.geo_entity_id IS NULL
              ) AND (
                api_cites_suspensions_view.taxon_concept_id = ANY(
                  linking_taxon_concept.ancestor_taxon_concept_ids
                )
              )
            )
          )
        SQL
      ).order('linking_taxon_concept.id ASC, api_cites_suspensions_view.id ASC')
    end,
    foreign_key: 'linking_taxon_concept.id',
    class_name: 'CitesSuspension'

  has_many :cites_quotas_including_global,
    -> do
      select(
        'api_cites_quotas_view.*'
      ).from(
        TaxonConcept.from(
          TaxonConcept.cites_linking_taxon_concept_sql
        ), :linking_taxon_concept
      ).joins(
        <<-SQL.squish
          JOIN api_cites_quotas_view api_cites_quotas_view
          ON (
            (
              api_cites_quotas_view.taxon_concept_id = ANY(descendant_taxon_concept_ids)
            ) OR (
              (
                api_cites_quotas_view.taxon_concept_id = ANY(ancestor_taxon_concept_ids)
                OR
                api_cites_quotas_view.taxon_concept_id IS NULL
              ) AND api_cites_quotas_view.geo_entity_id = ANY(geo_entity_ids)
            )
          )
        SQL
      ).order('linking_taxon_concept.id ASC, api_cites_quotas_view.id ASC')
    end,
    foreign_key: 'linking_taxon_concept.id',
    class_name: 'Quota'

  def common_names_with_iso_code(languages = nil)
    unless languages && languages.present?
      return common_names
    end

    common_names.filter do |cn|
      languages.include?(cn.iso_code1)
    end
  end

  def is_accepted_name?
    name_status == 'A'
  end

  def is_synonym?
    name_status == 'S'
  end

  private

  def self.cites_linking_taxon_concept_sql
    <<-SQL.squish
      (
        SELECT
          tc.id,
          TRUE AS taxonomy_is_cites_eu,
          array_agg(DISTINCT dtc.taxon_concept_id) AS descendant_taxon_concept_ids,
          array_agg(DISTINCT atc.ancestor_taxon_concept_id) AS ancestor_taxon_concept_ids,
          array_agg(DISTINCT d.geo_entity_id) AS geo_entity_ids
        FROM taxon_concepts_mview tc
        LEFT OUTER JOIN taxon_concepts_and_ancestors_mview atc
          ON atc.taxon_concept_id = tc.id
        LEFT OUTER JOIN distributions d
          ON d.taxon_concept_id = tc.id
        LEFT OUTER JOIN taxon_concepts_and_ancestors_mview dtc
          ON dtc.ancestor_taxon_concept_id = tc.id
        WHERE tc.taxonomy_is_cites_eu
        GROUP BY tc.id
      ) api_taxon_concepts_view
    SQL
  end
end
