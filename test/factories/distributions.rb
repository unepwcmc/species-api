module Test
  class Distribution < ActiveRecord::Base
    self.table_name = :distributions_mview
    self.primary_key = :id
  end
end

FactoryGirl.define do
  factory :distribution, class: Test::Distribution do
    sequence(:taxon_concept_id)
    sequence(:name_en) { |n| "name_en_#{n}"}
    sequence(:name_es) { |n| "name_es_#{n}"}
    sequence(:name_fr) { |n| "name_fr_#{n}"}
    iso_code2 "GB"
    geo_entity_type "COUNTRY"
  end
end




