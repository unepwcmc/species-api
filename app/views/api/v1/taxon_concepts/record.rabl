attributes :id, :full_name, :author_year, :rank, :name_status, :taxonomy, :updated_at, :active

node(:accepted_names, if: :is_synonym?) { |tc| tc.accepted_names }

node(:higher_taxa, if: :is_accepted_name?) { |tc| tc.higher_taxa }
node(:synonyms, if: :is_accepted_name?) { |tc| tc.synonyms }

node(:common_names, if: :is_accepted_name?) do |tc|
  (tc.common_names_list || tc.common_names).map do |cn|
    {
      name: cn['name'],
      language: cn['iso_code1']
    }
  end
end

attribute :cites_listing, if: :is_accepted_name?

node(
  :cites_listings, if: :is_accepted_name?
) do |tc|
  collection (tc.cites_listings_list || tc.current_cites_additions)
  extends 'api/v1/cites_legislation/cites_listing'
end

attribute :eu_listing, if: :is_accepted_name?

if 'true' == @eu_listings
  node(:eu_listings, if: :is_accepted_name?) do |tc|
    collection (tc.current_eu_additions)
    extends 'api/v1/eu_legislation/eu_listing'
  end
end
