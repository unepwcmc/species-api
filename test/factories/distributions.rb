FactoryGirl.define do
  factory :distribution, class: Distribution do
    association :taxon_concept
    association :geo_entity
    # created_at: datetime
    # updated_at: datetime
    # created_by_id: intege
    # updated_by_id: integer
    internal_notes "Some notes go here"
  end

  factory :geo_entity, class: GeoEntity do
    association :geo_entity_type
    sequence(:name_en) { |n| "name_en_#{n}"}
    sequence(:name_es) { |n| "name_es_#{n}"}
    sequence(:name_fr) { |n| "name_fr_#{n}"}
    long_name "Whatever"
    iso_code2 "GB"
    iso_code3 "Longer"
    #legacy_id integer
    #legacy_type string
    is_current true
  end

  factory :geo_entity_type, class: GeoEntityType do
    name "String"
  end

  factory :distribution_reference, class: DistributionReference do
    association :distribution
    association :reference
    #updated_by_id: integer
    #created_by_id: integer
  end

  factory :reference, class: Reference do
    title "This is a title"
    year "1988"
    author "Jim Henson"
    citation "Citations yo"
    publisher "Michael Jackson"
    #legacy_id integer
    #legacy_type string
    #updated_by_id integer
    #created_by_id integer
  end
end





