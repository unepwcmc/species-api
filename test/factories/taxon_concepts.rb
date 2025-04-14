Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}

FactoryBot.define do
  factory :taxon_concept, class: Test::TaxonConcept do
    association :taxonomy
    association :taxon_name
    association :rank
    sequence(:full_name) { |n| "Canis lupus#{n}" }
    name_status { 'A' }
  end

  factory :taxonomy, class: Test::Taxonomy do
    name { 'CITES_EU' }
  end

  factory :rank, class: Test::Rank do
    name { 'SPECIES' }
    display_name_en { name&.humanize || 'Species' }
    display_name_es { name&.humanize || 'Species' }
    display_name_fr { name&.humanize || 'Species' }

    to_create do |instance|
      instance.attributes =
        instance.class.find_or_create_by(
          name: instance.name,
          display_name_en: instance.name&.humanize,
          display_name_es: instance.name&.humanize,
          display_name_fr: instance.name&.humanize
        ).attributes
      instance.reload
    end
  end

  factory :taxon_name, class: Test::TaxonName do
    sequence(:scientific_name) { |n| "lupus#{n}" }
  end
end
