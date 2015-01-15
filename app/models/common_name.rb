# == Schema Information
#
# Table name: api_common_names_view
#
#  id               :integer          primary key
#  taxon_concept_id :integer
#  iso_code1        :string(255)
#  name             :string(255)
#

class CommonName < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_common_names_view
  self.primary_key = :id

  belongs_to :taxon_concept
end
