Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}
FactoryGirl.define do
  factory :common_name, class: Test::CommonName do
    sequence(:name) { |n| "Common name #{n}" }
    language
  end

  factory :taxon_common, class: Test::TaxonCommon do
    taxon_concept
    common_name
  end

  factory :language, class: Test::Language do
    name_en "English Name"
    name_fr "French Name"
    name_es "Spanish Name"
    iso_code1 "EN"
    iso_code3 "English"
  end
end