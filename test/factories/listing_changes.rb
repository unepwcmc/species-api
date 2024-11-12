FactoryGirl.define do
  factory :designation, class: Test::Designation do
    taxonomy
    name { 'CITES' }
  end

  factory :change_type, class: Test::ChangeType do
    designation
    name { 'ADDITION' }
    display_name_en { 'Addition' }
  end

  factory :species_listing, class: Test::SpeciesListing do
    designation
    name { 'Appendix I' }
  end

  factory :listing_change, class: Test::ListingChange do
    taxon_concept
    change_type
    species_listing
    effective_at { Date.new(2012, 12, 3) }
    is_current { true }
  end
end
