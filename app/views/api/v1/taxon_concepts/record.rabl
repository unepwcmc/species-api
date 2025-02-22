attributes :id, :full_name, :author_year, :rank, :name_status, :taxonomy, :updated_at, :active

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

node(:cites_listings, if: :is_accepted_name?) do |tc|
  (tc.cites_listings_list || tc.current_cites_additions).map do |cl|
    {
      id: cl.id,
      appendix: cl.species_listing_name,
      annotation: cl.annotation,
      hash_annotation: cl.hash_annotation,
      effective_at: cl.effective_at,
      party: cl.party
    }
  end
end

attribute :eu_listing, if: :is_accepted_name?

if 'true' == @eu_listings
  node(:eu_listings, if: :is_accepted_name?) do |tc|
    tc.current_eu_additions.map do |el|
      {
        :id => el.id,
        :annex => el.species_listing_name,
        :annotation => el.annotation,
        :hash_annotation => el.hash_annotation,
        :effective_at => el.effective_at,
        :party=> el.party
      }
    end
  end
end

node(:accepted_names, if: :is_synonym?) { |tc| tc.accepted_names }
