child :pagination do
  node(:current_page){ @taxon_concepts.current_page.to_i }
  node(:per_page){ @taxon_concepts.per_page }
  node(:total_entries){ @taxon_concepts.total_entries }
end

child @taxon_concepts => :taxon_concepts do
  node do |taxon_concept|
    partial('api/v1/taxon_concepts/record', object: taxon_concept)
  end
end