FactoryGirl.define do
  factory :designation, class: Test::Designation do
    association :taxonomy
    name { 'CITES' }
  end

  factory :change_type, class: Test::ChangeType do
    association :designation
    name { 'ADDITION' }
    display_name_en { 'Addition' }
  end

  factory :species_listing, class: Test::SpeciesListing do
    association :designation
    name { 'Appendix I' }
  end

  factory :listing_change, class: Test::ListingChange do
    association :taxon_concept
    association :change_type
    association :species_listing
    effective_at { Date.new(2012, 12, 3) }
    is_current { true }
  end
end
