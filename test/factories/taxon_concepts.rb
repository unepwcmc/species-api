FactoryGirl.define do
  factory :taxon_concept do
    sequence(:full_name) { |n| "Canis lupus#{n}" }
  end
end
