attributes :id, :taxon_concept_id, :notes, :start_date, :is_current, :applies_to_import

node(:geo_entity){ |cs| cs.geo_entity }

node(:start_notification){ |cs| cs.start_notification }
