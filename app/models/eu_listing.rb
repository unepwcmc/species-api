# == Schema Information
#
# Table name: api_eu_listing_changes_view
#
#  id                         :integer          primary key
#  event_id                   :integer
#  eu_regulation              :json
#  taxon_concept_id           :integer
#  original_taxon_concept_id  :integer
#  is_current                 :boolean
#  effective_at               :date
#  species_listing_name       :string(255)
#  change_type_name           :string(255)
#  change_type                :text
#  inclusion_taxon_concept_id :integer
#  party_id                   :integer
#  party_en                   :json
#  party_es                   :json
#  party_fr                   :json
#  annotation_en              :text
#  annotation_es              :text
#  annotation_fr              :text
#  hash_annotation_en         :json
#  hash_annotation_es         :json
#  hash_annotation_fr         :json
#  show_in_history            :boolean
#  full_note_en               :text
#  short_note_en              :text
#  auto_note_en               :text
#  hash_full_note_en          :text
#  hash_ann_parent_symbol     :string(255)
#  hash_ann_symbol            :string(255)
#  inherited_full_note_en     :text
#  inherited_short_note_en    :text
#  nomenclature_note_en       :text
#  nomenclature_note_fr       :text
#  nomenclature_note_es       :text
#  change_type_order          :integer
#

class EuListing < ActiveRecord::Base
  include Scope
  after_initialize :readonly!
  self.table_name = :api_eu_listing_changes_view
  self.primary_key = :id

  translates :party, :annotation, :hash_annotation

  belongs_to :taxon_concept
end
