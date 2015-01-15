# == Schema Information
#
# Table name: api_cites_suspensions_view
#
#  id                         :integer          primary key
#  type                       :string(255)
#  taxon_concept_id           :integer
#  notes                      :text
#  start_date                 :date
#  end_date                   :date
#  is_current                 :boolean
#  geo_entity_id              :integer
#  start_notification_id      :integer
#  end_notification_id        :integer
#  nomenclature_note_en       :text
#  nomenclature_note_fr       :text
#  nomenclature_note_es       :text
#  taxon_concept              :json
#  matching_taxon_concept_ids :integer          is an Array
#  geo_entity_en              :json
#  geo_entity_es              :json
#  geo_entity_fr              :json
#  start_notification         :json
#

class CitesSuspension < ActiveRecord::Base
  include Scope
  after_initialize :readonly!
  self.table_name = :api_cites_suspensions_view
  self.primary_key = :id

  translates :geo_entity

  belongs_to :taxon_concept
end
