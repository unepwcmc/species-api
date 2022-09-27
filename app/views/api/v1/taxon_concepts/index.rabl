child :pagination do
  node(:current_page){ @taxon_concepts.current_page.to_i }
  node(:per_page){ @taxon_concepts.per_page }
  node(:total_entries){ @taxon_concepts.total_entries }
end

child @taxon_concepts => :taxon_concepts do
  attributes :id, :full_name, :author_year, :rank, :name_status,
    :taxonomy, :updated_at, :active
  node(:higher_taxa, if: :is_accepted_name?) { |tc| tc.higher_taxa }
  node(:synonyms, if: :is_accepted_name?) { |tc| tc.synonyms }

  node(:common_names, if: :is_accepted_name?) { |tc|
    tc.common_names_list.map do |cn|
      {:name => cn.name, :language => cn.iso_code1}
    end
  }

  attribute :cites_listing, if: :is_accepted_name?
  node(:cites_listings, if: :is_accepted_name?) { |tc|
    tc.cites_listings_list.map do |cl|
      {
        :id => cl.id,
        :appendix => cl.species_listing_name,
        :annotation => cl.annotation,
        :hash_annotation => cl.hash_annotation,
        :effective_at => cl.effective_at,
        :party=> cl.party
      }
    end
  }

  attribute :eu_listing, if: :is_accepted_name?
  node(:eu_listings, if: :is_accepted_name?) { |tc|
    tc.eu_listings_list.map do |el|
      {
        :id => el.id,
        :appendix => el.species_listing_name,
        :annotation => el.annotation,
        :hash_annotation => el.hash_annotation,
        :effective_at => el.effective_at,
        :party=> el.party
      }
    end
  }
  node(:accepted_names, if: :is_synonym?) { |tc| tc.accepted_names }
end
