attributes :id, :taxon_concept_id, :quota, :publication_date, :notes, :url, :public_display, :is_current

node(:unit){ |cs| cs.unit }

node(:geo_entity){ |cs| cs.geo_entity }
