object @taxon_concept => :cites_legislation
attributes :id => :taxon_concept_id

child @cites_listings => :cites_listings do
  attribute :id
end

child :cites_quotas => :cites_quotas do
  attributes :quota, :publication_date, :notes, :url, :public_display, :is_current, :unit_name 

  child :geo_entity_id => :geo_entity do
    attributes :id, :name, :iso_code2, :geo_entity_type
  end
end

child :cites_suspensions => :cites_suspensions do
  attributes :notes, :start_date, :is_current

  child :geo_entity_id => :geo_entity do
    attributes :id, :name, :iso_code2, :geo_entity_type
  end

  child :start_notification_id => :start_notification do
    attributes :name, :effective_at_formatted, :url
  end
end
