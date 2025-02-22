attributes :id, :taxon_concept_id, :notes, :start_date, :is_current

node(:eu_decision_type){ |ed| ed.eu_decision_type }

node(:geo_entity){ |ed| ed.geo_entity }

node(:start_event){ |ed| ed.start_event }

node(:source){ |ed| ed.source }

node(:term){ |ed| ed.term }
