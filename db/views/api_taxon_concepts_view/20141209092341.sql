SELECT
  tc.id,
  tc.parent_id,
  CASE WHEN tc.taxonomy_is_cites_eu THEN 'CITES' ELSE 'CMS' END AS taxonomy,
  tc.taxonomy_is_cites_eu,
  tc.full_name,
  tc.spp,
  tc.author_year,
  'A' AS name_status,
  tc.rank_name AS rank,
  tc.taxonomic_position,
  ROW_TO_JSON(
    ROW(
      tc.kingdom_name, tc.phylum_name, tc.class_name, tc.order_name, tc.family_name
    )::higher_taxa
  ) AS higher_taxa,
  ARRAY_TO_JSON(
    ARRAY_AGG_NOTNULL(
      ROW(
        synonyms.id, synonyms.full_name, synonyms.author_year
      )::simple_taxon_concept
    )
  ) AS synonyms,
  NULL AS accepted_names,
  tc.created_at,
  tc.updated_at
FROM taxon_concepts_mview tc
LEFT JOIN taxon_relationships tr
  ON tr.taxon_concept_id = tc.id
LEFT JOIN taxon_relationship_types trt
  ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_SYNONYM'
LEFT JOIN taxon_concepts_mview synonyms
  ON synonyms.id = tr.other_taxon_concept_id
WHERE tc.name_status = 'A'
GROUP BY tc.id, tc.parent_id, tc.taxonomy_is_cites_eu, tc.full_name, tc.spp, tc.author_year, tc.rank_name,
tc.taxonomic_position, tc.kingdom_name, tc.phylum_name, tc.class_name, tc.order_name, tc.family_name,
tc.created_at, tc.updated_at

UNION ALL

SELECT
  tc.id,
  NULL AS parent_id,
  CASE WHEN tc.taxonomy_is_cites_eu THEN 'CITES' ELSE 'CMS' END AS taxonomy,
  tc.taxonomy_is_cites_eu,
  tc.full_name,
  tc.spp,
  tc.author_year,
  'S' AS name_status,
  tc.rank_name AS rank,
  NULL AS taxonomic_position,
  NULL::JSON AS higher_taxa,
  NULL AS synonyms,
  ARRAY_TO_JSON(
    ARRAY_AGG_NOTNULL(
      ROW(
        accepted_names.id, accepted_names.full_name, accepted_names.author_year
      )::simple_taxon_concept
    )
  ) AS accepted_names,
  tc.created_at,
  tc.updated_at
FROM taxon_concepts_mview tc
JOIN taxon_relationships tr
  ON tr.other_taxon_concept_id = tc.id
JOIN taxon_relationship_types trt
  ON trt.id = tr.taxon_relationship_type_id AND trt.name = 'HAS_SYNONYM'
JOIN taxon_concepts_mview accepted_names
  ON accepted_names.id = tr.taxon_concept_id
WHERE tc.name_status = 'S'
GROUP BY tc.id, tc.parent_id, tc.taxonomy_is_cites_eu, tc.full_name, tc.spp, tc.author_year, tc.rank_name,
tc.taxonomic_position, tc.kingdom_name, tc.phylum_name, tc.class_name, tc.order_name, tc.family_name,
tc.created_at, tc.updated_at;
