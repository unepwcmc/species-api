# == Schema Information
#
# Table name: api_cites_quotas_view
#
#  id                         :integer          primary key
#  type                       :string(255)
#  taxon_concept_id           :integer
#  notes                      :text
#  url                        :text
#  start_date                 :datetime
#  publication_date           :date
#  is_current                 :boolean
#  geo_entity_id              :integer
#  unit_id                    :integer
#  quota                      :float
#  public_display             :boolean
#  nomenclature_note_en       :text
#  nomenclature_note_fr       :text
#  nomenclature_note_es       :text
#  taxon_concept              :json
#  matching_taxon_concept_ids :integer          is an Array
#  geo_entity_en              :json
#  geo_entity_es              :json
#  geo_entity_fr              :json
#  unit_en                    :json
#  unit_es                    :json
#  unit_fr                    :json
#

class Quota < ActiveRecord::Base
  include Scope
  after_initialize :readonly!
  self.table_name = :api_cites_quotas_view
  self.primary_key = :id

  translates :geo_entity
  translates :unit

  belongs_to :taxon_concept
end
