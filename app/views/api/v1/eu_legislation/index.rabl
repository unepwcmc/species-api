object @taxon_concept => :eu_legislation

child @eu_listings => :eu_listings do
  attributes :taxon_concept_id, :is_current
  attributes :species_listing_name => :annex
  attributes :change_type, :effective_at

  node(:party, :if => lambda { |lc| lc.party }){ |lc| lc.party }

  node(:annotation, :if => lambda { |lc| lc.annotation }){ |lc| lc.annotation }

  node(:hash_annotation, :if => lambda { |lc| lc.hash_annotation }){ |lc| lc.hash_annotation }
end

child @eu_decisions => :eu_decisions do
  attributes :taxon_concept_id, :notes, :start_date, :is_current

  node(:eu_decision_type){ |ed| ed.eu_decision_type }

  node(:geo_entity){ |ed| ed.geo_entity }

  node(:start_event){ |ed| ed.start_event }

  node(:source){ |ed| ed.source }

  node(:term){ |ed| ed.term }

end
