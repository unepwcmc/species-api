# == Schema Information
#
# Table name: api_distributions_view
#
#  id               :integer          primary key
#  taxon_concept_id :integer
#  name_en          :string(255)
#  name_es          :string(255)
#  name_fr          :string(255)
#  iso_code2        :string(255)
#  geo_entity_type  :string(255)
#  tags             :string           is an Array
#  citations        :text             is an Array
#  created_at       :datetime
#  updated_at       :datetime
#

class Distribution < ApplicationRecord
  after_initialize :readonly!
  self.table_name = :api_distributions_view
  self.primary_key = :id

  translates :name

  belongs_to :taxon_concept
end
