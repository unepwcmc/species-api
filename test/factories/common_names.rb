Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}
FactoryGirl.define do
  factory :common_name, class: Test::TaxonCommon do
    sequence(:name) { |n| "Common name #{n}" }
    iso_code1 ['EN', 'DE'].sample
    taxon_concept_id
  end
end