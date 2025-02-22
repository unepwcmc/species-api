attributes :id, :taxon_concept_id, :is_current
attributes :species_listing_name => :appendix
attributes :change_type, :effective_at

node(:party, :if => lambda { |lc| lc.party }){ |lc| lc.party }

attributes :annotation

node(:hash_annotation, :if => lambda { |lc| lc.hash_annotation }){ |lc| lc.hash_annotation }
