collection @taxon_concepts
attributes :id, :full_name, :author_year, :rank_name, :name_status,
  :updated_at
node(:higher_taxa) { |tc| tc.higher_taxa }
node(:synonyms) { |tc| tc.synonyms }
