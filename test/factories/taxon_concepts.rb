Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}

FactoryBot.define do
  factory :taxon_concept, class: Test::TaxonConcept do
    association :taxonomy
    association :taxon_name
    association :rank
    sequence(:full_name) { |n| "Canis lupus#{n}" }
    name_status { 'A' }
  end

  factory :taxonomy, class: Test::Taxonomy do
    name { 'CITES_EU' }
  end

  factory :rank, class: Test::Rank do
    name { 'SPECIES' }
    display_name_en { 'SPECIES' }
  end

  factory :taxon_name, class: Test::TaxonName do
    sequence(:scientific_name) { |n| "lupus#{n}" }
  end
end
