module Test
  class TaxonConcept < ActiveRecord::Base
    self.table_name = :taxon_concepts_mview
    self.primary_key = :id
  end
end

FactoryGirl.define do
  factory :taxon_concept, class: Test::TaxonConcept do
    sequence(:full_name) { |n| "Canis lupus#{n}" }
    name_status 'A'
    taxonomy_is_cites_eu true
  end
end
