Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}

FactoryBot.define do
  factory :distribution, class: Test::Distribution do
    association :taxon_concept
    association :geo_entity
  end

  factory :geo_entity, class: Test::GeoEntity do
    association :geo_entity_type
    sequence(:name_en) { |n| "name en"}
    sequence(:name_es) { |n| "name es"}
    sequence(:name_fr) { |n| "name fr"}
    long_name { 'Whatever' }
    iso_code2 { 'GB' }
    iso_code3 { 'GBR' }
    is_current { true }
  end

  factory :geo_entity_type, class: Test::GeoEntityType do
    name { 'COUNTRY' }
  end
end
