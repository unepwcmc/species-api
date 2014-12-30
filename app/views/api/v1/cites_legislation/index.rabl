object @taxon_concept => :cites_legislation

child @cites_listings => :cites_listings do
  attributes :taxon_concept_id, :is_current
  attributes :species_listing_name => :appendix
  attributes :change_type, :effective_at

  node(:party, :if => lambda { |lc| lc.party }){ |lc| lc.party }

  node(:annotation, :if => lambda { |lc| lc.annotation }){ |lc| lc.annotation }

  node(:hash_annotation, :if => lambda { |lc| lc.hash_annotation }){ |lc| lc.hash_annotation }
end

child @cites_quotas => :cites_quotas do
  attributes :taxon_concept_id, :quota, :publication_date, :notes, :url, :public_display, :is_current

  node(:unit){ |cs| cs.unit }

  node(:geo_entity){ |cs| cs.geo_entity }
end

child @cites_suspensions => :cites_suspensions do
  attributes :taxon_concept_id, :notes, :start_date, :is_current

  node(:geo_entity){ |cs| cs.geo_entity }

  node(:start_notification){ |cs| cs.start_notification }

end
