# == Schema Information
#
# Table name: api_eu_decisions_view
#
#  type                 :string(255)
#  taxon_concept_id     :integer
#  taxon_concept        :json
#  notes                :text
#  start_date           :date
#  is_current           :boolean
#  geo_entity_id        :integer
#  geo_entity_en        :json
#  geo_entity_es        :json
#  geo_entity_fr        :json
#  start_event_id       :integer
#  start_event          :json
#  end_event_id         :integer
#  end_event            :json
#  term_id              :integer
#  term_en              :json
#  term_es              :json
#  term_fr              :json
#  source_en            :json
#  source_es            :json
#  source_fr            :json
#  source_id            :integer
#  eu_decision_type_id  :integer
#  eu_decision_type     :json
#  nomenclature_note_en :text
#  nomenclature_note_fr :text
#  nomenclature_note_es :text
#

class EuSuspension < EuDecision; end
