Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}

FactoryGirl.define do
  factory :taxon_concept_reference, class: Test::TaxonConceptReference do
    association :taxon_concept
    association :reference
    is_standard { false }
  end

  factory :distribution_reference, class: Test::DistributionReference do
    association :distribution
    association :reference
  end

  factory :reference, class: Test::Reference do
    title { "This is a title" }
    year { "1988" }
    author { "Jim Henson" }
    citation { "Citations yo" }
    publisher { "Michael Jackson" }
  end
end
