collection @taxon_concepts
attributes :id, :full_name, :author_year, :rank, :name_status,
  :taxonomy, :updated_at
node(:higher_taxa) { |tc| tc.higher_taxa }
node(:synonyms) { |tc| tc.synonyms }
