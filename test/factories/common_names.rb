Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}
FactoryGirl.define do
  factory :common_name, class: Test::CommonName do
    sequence(:name) { |n| "Common name #{n}" }
    iso_code1 'EN'
    taxon_concept
  end

  factory :taxon_common, class: Test::TaxonCommon do
  end

  factory :language, class: Test::Language do
  end
end