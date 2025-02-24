# associations relevat to accepted names, but which are only summaries for the
# taxon view. These are not included in the dump, as dumpable_associations
# contains all cites_listings and eu_listings.

node(:cites_listings) do |tc|
  tc.current_cites_additions.map do |cl|
    partial('api/v1/cites_legislation/cites_listing', :object => cl)
  end
end

if 'true' == @eu_listings
  node(:eu_listings) do |tc|
    tc.current_eu_additions.map do |el|
      partial('api/v1/eu_legislation/eu_listing', :object => el)
    end
  end
end
