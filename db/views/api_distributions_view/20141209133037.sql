SELECT
  d.id,
  d.taxon_concept_id,
  g.name_en,
  g.name_es,
  g.name_fr,
  g.iso_code2,
  gt.name AS geo_entity_type,
  d.created_at,
  d.updated_at
FROM distributions d
JOIN geo_entities g ON g.id = d.geo_entity_id
JOIN geo_entity_types gt ON gt.id = g.geo_entity_type_id;
