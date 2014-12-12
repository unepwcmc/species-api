module Test
  class Distribution < ActiveRecord::Base
    self.table_name = :distributions
    self.primary_key = :id
  end

  class GeoEntity < ActiveRecord::Base
    self.table_name = :geo_entity
    self.primary_key = :id
  end

  class GeoEntityType < ActiveRecord::Base
    self.table_name = :geo_entity_type
    self.primary_key = :id
  end

  class DistributionReference < ActiveRecord::Base
    self.table_name = :distribution_reference
    self.primary_key = :id
  end

  class Reference < ActiveRecord::Base
    self.table_name = :reference
    self.primary_key = :id
  end
end

FactoryGirl.define do
  factory :distribution, class: Test::Distribution do
    association :taxon_concept
    association :geo_entity
    # created_at: datetime
    # updated_at: datetime
    # created_by_id: intege
    # updated_by_id: integer
    internal_notes "Some notes go here"
  end

  factory :geo_entity, class: Test::GeoEntity do
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

  factory :geo_entity_type, class: Test::GeoEntityType do
    name string
  end

  factory :distribution_reference, class: Test::DistributionReference do
    association :distribution
    association :reference
    #updated_by_id: integer
    #created_by_id: integer
  end

  factory :reference, class: Test::Reference do
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





