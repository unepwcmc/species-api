collection @taxon_concepts
attributes :id, :full_name, :author_year, :rank, :name_status,
  :taxonomy, :updated_at, :cites_listing
node(:higher_taxa) { |tc| tc.higher_taxa }
node(:synonyms) { |tc| tc.synonyms }

node(:common_names) { |tc|
  common_names = tc.common_names.where("iso_code1 IS NOT NULL")
  common_names = common_names.where(iso_code1: @languages) unless
    @languages.nil?

  common_names.map do |cn|
    {:name => cn.name, :iso_code1 => cn.iso_code1}
  end
}

node(:cites_listings) { |tc|
  tc.cites_listings.where(is_current: true).map do |cl|
    hash_annotation = cl.hash_annotation || ''
    {
      :appendix => cl.species_listing_name,
      :annotation => cl.annotation,
      :hash_annotation => hash_annotation
    }
  end
}