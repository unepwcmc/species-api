child :pagination do
  @pagination.each do |ky, v|
    node(ky){ v }
  end
end

child @taxon_concepts => :taxon_concepts do
attributes :id, :full_name, :author_year, :rank, :name_status,
  :taxonomy, :updated_at
node(:higher_taxa) { |tc| tc.higher_taxa }
node(:synonyms) { |tc| tc.synonyms }

node(:common_names) { |tc|
  common_names = tc.common_names.where("iso_code1 IS NOT NULL")
  common_names = common_names.where(iso_code1: @languages) unless
    @languages.nil?

  common_names.map do |cn|
    {:name => cn.name, :language => cn.iso_code1}
  end
}

attributes :cites_listing
node(:cites_listings) { |tc|
  tc.cites_listings.where(is_current: true, change_type_name: 'ADDITION').map do |cl|
    {
      :appendix => cl.species_listing_name,
      :annotation => cl.annotation,
      :hash_annotation => cl.hash_annotation
    }
  end
}
end
