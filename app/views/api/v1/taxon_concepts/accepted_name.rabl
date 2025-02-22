# Most relevant relationships belong to accepted names, so this file focuses
# just on the attributes relating to accepted names.

node(:higher_taxa) { |tc| tc.higher_taxa }
node(:synonyms) { |tc| tc.synonyms }

node(:common_names) do |tc|
  (tc.common_names_list || tc.common_names).map do |cn|
    # Can't use partial+attributes because these might just be hashes
    {
      name: cn['name'],
      language: cn['iso_code1']
    }
  end
end

attribute :cites_listing

node(:cites_listings) do |tc|
  (tc.cites_listings_list || tc.current_cites_additions).map do |cl|
    partial('api/v1/cites_legislation/cites_listing', :object => cl)
  end
end

attribute :eu_listing

if 'true' == @eu_listings
  node(:eu_listings) do |tc|
    tc.current_eu_additions.map do |el|
      partial('api/v1/eu_legislation/eu_listing', :object => el)
    end
  end
end
