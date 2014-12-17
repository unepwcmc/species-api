--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: binary_upgrade; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA binary_upgrade;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


SET search_path = public, pg_catalog;

--
-- Name: event_properties; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE event_properties AS (
	id integer,
	full_name json,
	taxonomy_name text,
	rank_name json,
	family_name json
);


--
-- Name: higher_taxa; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE higher_taxa AS (
	kingdom text,
	phylum text,
	class text,
	"order" text,
	family text
);


--
-- Name: simple_taxon_concept; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE simple_taxon_concept AS (
	id integer,
	full_name text,
	author_year text
);


SET search_path = binary_upgrade, pg_catalog;

--
-- Name: create_empty_extension(text, text, boolean, text, oid[], text[], text[]); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION create_empty_extension(text, text, boolean, text, oid[], text[], text[]) RETURNS void
    LANGUAGE c
    AS '$libdir/pg_upgrade_support', 'create_empty_extension';


--
-- Name: set_next_array_pg_type_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_array_pg_type_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_array_pg_type_oid';


--
-- Name: set_next_heap_pg_class_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_heap_pg_class_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_heap_pg_class_oid';


--
-- Name: set_next_index_pg_class_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_index_pg_class_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_index_pg_class_oid';


--
-- Name: set_next_pg_authid_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_pg_authid_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_pg_authid_oid';


--
-- Name: set_next_pg_enum_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_pg_enum_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_pg_enum_oid';


--
-- Name: set_next_pg_type_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_pg_type_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_pg_type_oid';


--
-- Name: set_next_toast_pg_class_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_toast_pg_class_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_toast_pg_class_oid';


--
-- Name: set_next_toast_pg_type_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_toast_pg_type_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_toast_pg_type_oid';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: listing_changes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE listing_changes (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    species_listing_id integer,
    change_type_id integer NOT NULL,
    annotation_id integer,
    hash_annotation_id integer,
    effective_at timestamp without time zone DEFAULT '2012-09-21 07:32:20'::timestamp without time zone NOT NULL,
    is_current boolean DEFAULT false NOT NULL,
    parent_id integer,
    inclusion_taxon_concept_id integer,
    event_id integer,
    original_id integer,
    explicit_change boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    import_row_id integer,
    created_by_id integer,
    updated_by_id integer,
    internal_notes text
);


--
-- Name: taxon_concepts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concepts (
    id integer NOT NULL,
    taxonomy_id integer DEFAULT 1 NOT NULL,
    parent_id integer,
    rank_id integer NOT NULL,
    taxon_name_id integer NOT NULL,
    author_year character varying(255),
    legacy_id integer,
    legacy_type character varying(255),
    data hstore,
    listing hstore,
    notes text,
    taxonomic_position character varying(255) DEFAULT '0'::character varying NOT NULL,
    full_name character varying(255),
    name_status character varying(255) DEFAULT 'A'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    touched_at timestamp without time zone,
    legacy_trade_code character varying(255),
    updated_by_id integer,
    created_by_id integer,
    dependents_updated_at timestamp without time zone
);


--
-- Name: ancestor_listing_auto_note(taxon_concepts, listing_changes, character); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ancestor_listing_auto_note(taxon_concept taxon_concepts, listing_change listing_changes, locale character) RETURNS text
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    result TEXT;
  BEGIN
    IF NOT ARRAY[LOWER(locale)] && ARRAY['en', 'es', 'fr'] THEN
      locale := 'en';
    END IF;
    EXECUTE 'SELECT
      UPPER(COALESCE(
        ranks.display_name_' || locale || ',
        ranks.display_name_en,
        ranks.name
      )) || '' '' ||
      COALESCE(
        change_types.display_name_' || locale || ',
        change_types.display_name_en,
        change_types.name
      ) || '' '' ||
      full_name_with_spp(ranks.name, ''' || taxon_concept.full_name || ''')
      FROM ranks, change_types
      WHERE ranks.id = ' || taxon_concept.rank_id || '
      AND change_types.id = ' || listing_change.change_type_id
    INTO result;
    RETURN result;
  END;
  $$;


--
-- Name: ancestor_listing_auto_note_en(taxon_concepts, listing_changes); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ancestor_listing_auto_note_en(taxon_concepts, listing_changes) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT * FROM ancestor_listing_auto_note($1, $2, 'en');
  $_$;


--
-- Name: FUNCTION ancestor_listing_auto_note_en(taxon_concepts, listing_changes); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION ancestor_listing_auto_note_en(taxon_concepts, listing_changes) IS 'Returns English auto note (used for inherited listing changes).';


--
-- Name: ancestor_listing_auto_note_es(taxon_concepts, listing_changes); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ancestor_listing_auto_note_es(taxon_concepts, listing_changes) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT * FROM ancestor_listing_auto_note($1, $2, 'es');
  $_$;


--
-- Name: FUNCTION ancestor_listing_auto_note_es(taxon_concepts, listing_changes); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION ancestor_listing_auto_note_es(taxon_concepts, listing_changes) IS 'Returns Spanish auto note (used for inherited listing changes).';


--
-- Name: ancestor_listing_auto_note_fr(taxon_concepts, listing_changes); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ancestor_listing_auto_note_fr(taxon_concepts, listing_changes) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT * FROM ancestor_listing_auto_note($1, $2, 'fr');
  $_$;


--
-- Name: FUNCTION ancestor_listing_auto_note_fr(taxon_concepts, listing_changes); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION ancestor_listing_auto_note_fr(taxon_concepts, listing_changes) IS 'Returns French auto note (used for inherited listing changes).';


--
-- Name: ancestor_node_ids_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ancestor_node_ids_for_node(node_id integer) RETURNS integer[]
    LANGUAGE sql STABLE
    AS $_$
    WITH RECURSIVE ancestors AS (
      SELECT h.id, h.parent_id
      FROM taxon_concepts h WHERE id = $1

      UNION

      SELECT hi.id, hi.parent_id
      FROM taxon_concepts hi JOIN ancestors ON hi.id = ancestors.parent_id
    )
    SELECT ARRAY(SELECT id FROM ancestors);
  $_$;


--
-- Name: ancestors_names(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ancestors_names(node_id integer) RETURNS hstore
    LANGUAGE sql
    AS $_$
    WITH RECURSIVE q AS (
      SELECT h.id, h.parent_id,
        HSTORE(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
        HSTORE(LOWER(ranks.name) || '_id', h.id::VARCHAR) AS ancestors
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = $1

      UNION

      SELECT hi.id, hi.parent_id, q.ancestors ||
        HSTORE(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
        HSTORE(LOWER(ranks.name) || '_id', hi.id::VARCHAR)
      FROM q
      JOIN taxon_concepts hi
      ON hi.id = q.parent_id
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    SELECT ancestors FROM q WHERE parent_id IS NULL;
  $_$;


--
-- Name: array_intersect(anyarray, anyarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION array_intersect(anyarray, anyarray) RETURNS anyarray
    LANGUAGE sql
    AS $_$
    SELECT ARRAY(
        SELECT UNNEST($1)
        INTERSECT
        SELECT UNNEST($2)
    );
$_$;


--
-- Name: cites_aggregate_children_listing(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cites_aggregate_children_listing(node_id integer) RETURNS hstore
    LANGUAGE sql STABLE
    AS $_$
    WITH aggregated_children_listing AS (
      SELECT
      -- this to be used in the timelines: if there are explicitly listed
      -- descendants, the timeline might differ from the current listing
      -- and a note should be displayed to inform the user
      hstore('cites_listed_descendants', BOOL_OR(
        (listing -> 'cites_status_original')::BOOLEAN
        OR (listing -> 'cites_listed_descendants')::BOOLEAN
      )::VARCHAR) ||
      hstore('cites_I', MAX((listing -> 'cites_I')::VARCHAR)) ||
      hstore('cites_II', MAX((listing -> 'cites_II')::VARCHAR)) ||
      hstore('cites_III', MAX((listing -> 'cites_III')::VARCHAR)) ||
      hstore('cites_NC', MAX((listing -> 'cites_not_listed')::VARCHAR)) ||
      hstore('cites_listing', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[
            (MAX(listing -> 'cites_I')::VARCHAR),
            (MAX(listing -> 'cites_II')::VARCHAR),
            (MAX(listing -> 'cites_III')::VARCHAR),
            (MAX(listing -> 'cites_not_listed')::VARCHAR)
          ]) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM taxon_concepts
      WHERE
        -- aggregate children's listings
        parent_id = $1
        -- as well as parent if they're explicitly listed
        OR (
          id = $1
          AND (listing->'cites_status_original')::BOOLEAN
        )
        -- as well as parent if they are species
        -- the assumption being they will have subspecies
        -- which are not listed in their own right and
        -- should therefore inherit the cascaded listing
        -- if one exists
        -- this should fix Lutrinae species, which should be I/II
        -- even though subspecies in the db are on I
        OR (
          id = $1
          AND data->'rank_name' = 'SPECIES'
        )
    )
    SELECT listing
    FROM aggregated_children_listing;
  $_$;


--
-- Name: cites_applicable_listing_changes_for_node(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cites_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer) RETURNS SETOF integer
    LANGUAGE sql STABLE STRICT
    AS $_$
  SELECT * FROM cites_eu_applicable_listing_changes_for_node($1, $2);
$_$;


--
-- Name: FUNCTION cites_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cites_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer) IS 'Returns applicable listing changes for a given node, including own and ancestors (following CITES cascading rules).';


--
-- Name: cites_eu_applicable_listing_changes_for_node(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cites_eu_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer) RETURNS SETOF integer
    LANGUAGE plpgsql STABLE STRICT
    AS $_$
DECLARE
  sql TEXT;
BEGIN
  sql := 'WITH RECURSIVE listing_changes_timeline AS (
    SELECT all_listing_changes_mview.id,
    designation_id,
    affected_taxon_concept_id AS original_taxon_concept_id,
    taxon_concept_id AS current_taxon_concept_id,
    CASE
      WHEN inclusion_taxon_concept_id IS NULL
      THEN HSTORE(species_listing_id::TEXT, taxon_concept_id::TEXT)
      ELSE HSTORE(species_listing_id::TEXT, inclusion_taxon_concept_id::TEXT)
    END AS context,
    inclusion_taxon_concept_id,
    species_listing_id,
    change_type_id,
    event_id,
    effective_at,
    tree_distance AS context_tree_distance,
    timeline_position,
    CASE
     WHEN (
      -- there are listed populations
      ARRAY_UPPER(listed_geo_entities_ids, 1) IS NOT NULL
      -- and the taxon has its own distribution and does not occur in any of them
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND NOT listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
    )
    -- when all populations are excluded
    OR (
      ARRAY_UPPER(excluded_geo_entities_ids, 1) IS NOT NULL
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
    )
    THEN FALSE
    WHEN ARRAY_UPPER(excluded_taxon_concept_ids, 1) IS NOT NULL
    -- if taxon or any of its ancestors is excluded from this listing
    AND excluded_taxon_concept_ids && ARRAY[
      affected_taxon_concept_id,
      taxon_concepts_mview.kingdom_id,
      taxon_concepts_mview.phylum_id,
      taxon_concepts_mview.class_id,
      taxon_concepts_mview.order_id,
      taxon_concepts_mview.family_id,
      taxon_concepts_mview.genus_id,
      taxon_concepts_mview.species_id
    ]
    THEN FALSE
    ELSE
    TRUE
    END AS is_applicable
    FROM ' || all_listing_changes_mview || ' all_listing_changes_mview
    JOIN cites_eu_tmp_taxon_concepts_mview taxon_concepts_mview
    ON all_listing_changes_mview.affected_taxon_concept_id = taxon_concepts_mview.id
    WHERE all_listing_changes_mview.affected_taxon_concept_id = $1
    AND timeline_position = 1

    UNION

    SELECT hi.id,
    hi.designation_id,
    listing_changes_timeline.original_taxon_concept_id,
    hi.taxon_concept_id,
    CASE
    WHEN hi.inclusion_taxon_concept_id IS NOT NULL
    AND (
      AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
      OR listing_changes_timeline.context = ''''::HSTORE
    )
    THEN HSTORE(hi.species_listing_id::TEXT, hi.inclusion_taxon_concept_id::TEXT)
    WHEN change_types.name = ''DELETION''
    AND hi.taxon_concept_id = hi.affected_taxon_concept_id
    THEN listing_changes_timeline.context - ARRAY[hi.species_listing_id::TEXT]
    WHEN change_types.name = ''DELETION''
    THEN listing_changes_timeline.context - HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    -- if it is a new listing at closer level that replaces an older listing, wipe out the context
    WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
    AND hi.effective_at > listing_changes_timeline.effective_at
    AND change_types.name = ''ADDITION''
    THEN HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    -- if it is a same day split listing we don''t want to wipe the other part of the split from the context
    WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
    AND change_types.name = ''ADDITION''
    THEN listing_changes_timeline.context || HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    WHEN hi.tree_distance <= listing_changes_timeline.context_tree_distance
    AND hi.affected_taxon_concept_id = hi.taxon_concept_id
    AND change_types.name = ''ADDITION''
    THEN HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    -- changing this to <= breaks Ursus arctos isabellinus
    WHEN hi.tree_distance <= listing_changes_timeline.context_tree_distance
    AND change_types.name = ''ADDITION''
    THEN listing_changes_timeline.context || HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    ELSE listing_changes_timeline.context
    END,
    hi.inclusion_taxon_concept_id,
    hi.species_listing_id,
    hi.change_type_id,
    hi.event_id,
    hi.effective_at,
    CASE
    WHEN (
        hi.inclusion_taxon_concept_id IS NOT NULL
        AND AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
      ) OR hi.tree_distance < listing_changes_timeline.context_tree_distance
    THEN hi.tree_distance
    ELSE listing_changes_timeline.context_tree_distance
    END,
    hi.timeline_position,
    -- is applicable
    CASE
    WHEN (
      -- there are listed populations
      ARRAY_UPPER(hi.listed_geo_entities_ids, 1) IS NOT NULL
      -- and the taxon has its own distribution and does not occur in any of them
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND NOT hi.listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
    )
    -- when all populations are excluded
    OR (
      ARRAY_UPPER(hi.excluded_geo_entities_ids, 1) IS NOT NULL
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND hi.excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
    )
    THEN FALSE
    WHEN ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NOT NULL
    -- if taxon or any of its ancestors is excluded from this listing
    AND hi.excluded_taxon_concept_ids && ARRAY[
      hi.affected_taxon_concept_id,
      taxon_concepts_mview.kingdom_id,
      taxon_concepts_mview.phylum_id,
      taxon_concepts_mview.class_id,
      taxon_concepts_mview.order_id,
      taxon_concepts_mview.family_id,
      taxon_concepts_mview.genus_id,
      taxon_concepts_mview.species_id
    ]
    THEN FALSE
    WHEN listing_changes_timeline.context -> hi.species_listing_id::TEXT = hi.taxon_concept_id::TEXT
    OR hi.taxon_concept_id = listing_changes_timeline.original_taxon_concept_id
    -- this line to make Moschus leucogaster happy
    OR AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
    THEN TRUE
    WHEN listing_changes_timeline.context = ''''::HSTORE  --this would be the case when deleted
    AND (
      ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NOT NULL
      AND NOT hi.excluded_taxon_concept_ids && ARRAY[hi.affected_taxon_concept_id]
      OR ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NULL
    )
    AND hi.inclusion_taxon_concept_id IS NULL
    AND hi.change_type_name = ''ADDITION''
    THEN TRUE -- allows for re-listing
    WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
    THEN TRUE
    ELSE FALSE
    END
    FROM ' || all_listing_changes_mview || ' hi
    JOIN listing_changes_timeline
    ON hi.designation_id = listing_changes_timeline.designation_id
    AND listing_changes_timeline.original_taxon_concept_id = hi.affected_taxon_concept_id
    AND listing_changes_timeline.timeline_position + 1 = hi.timeline_position
    JOIN change_types ON hi.change_type_id = change_types.id
    JOIN cites_eu_tmp_taxon_concepts_mview taxon_concepts_mview
    ON hi.affected_taxon_concept_id = taxon_concepts_mview.id
  )
  SELECT listing_changes_timeline.id
  FROM listing_changes_timeline
  WHERE is_applicable
  ORDER BY timeline_position';

  RETURN QUERY EXECUTE sql USING node_id;
END;
$_$;


--
-- Name: cites_leaf_listing(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cites_leaf_listing(node_id integer) RETURNS hstore
    LANGUAGE sql STABLE
    AS $_$
    SELECT hstore(
      'cites_listing',
      ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(
          SELECT * FROM UNNEST(
            ARRAY[
              taxon_concepts.listing -> 'cites_I',
              taxon_concepts.listing -> 'cites_II',
              taxon_concepts.listing -> 'cites_III',
              taxon_concepts.listing -> 'cites_not_listed'
            ]
          ) s WHERE s IS NOT NULL
        ), '/'
      )
    )
    FROM taxon_concepts
    WHERE id = $1;
  $_$;


--
-- Name: cms_aggregate_children_listing(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cms_aggregate_children_listing(node_id integer) RETURNS hstore
    LANGUAGE sql STABLE
    AS $_$
    WITH aggregated_children_listing AS (
      SELECT
      -- this to be used in the timelines: if there are explicitly listed
      -- descendants, the timeline might differ from the current listing
      -- and a note should be displayed to inform the user
      hstore('cms_listed_descendants', BOOL_OR(
        (listing -> 'cms_status_original')::BOOLEAN
        OR (listing -> 'cms_listed_descendants')::BOOLEAN
      )::VARCHAR) ||
      hstore('cms_I', MAX((listing -> 'cms_I')::VARCHAR)) ||
      hstore('cms_II', MAX((listing -> 'cms_II')::VARCHAR)) ||
      hstore('cms_NC', MAX((listing -> 'cms_not_listed')::VARCHAR)) ||
      hstore('cms_listing', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[
            (MAX(listing -> 'cms_I')::VARCHAR),
            (MAX(listing -> 'cms_II')::VARCHAR),
            (MAX(listing -> 'cms_not_listed')::VARCHAR)
          ]) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM taxon_concepts
      WHERE
        -- NOTE: THIS WHERE CLAUSE DIFFERS FROM CITES & EU
        -- aggregate children's listings
        parent_id = $1
        -- as well as parent if they're explicitly listed
        OR (
          id = $1
          AND (listing->'cms_status_original')::BOOLEAN
        )
    )
    SELECT listing
    FROM aggregated_children_listing;
  $_$;


--
-- Name: cms_applicable_listing_changes_for_node(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cms_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer) RETURNS SETOF integer
    LANGUAGE plpgsql STABLE STRICT
    AS $_$
DECLARE
  sql TEXT;
BEGIN
  sql := 'WITH RECURSIVE listing_changes_timeline AS (
    SELECT all_listing_changes_mview.id,
    designation_id,
    affected_taxon_concept_id AS original_taxon_concept_id,
    taxon_concept_id AS current_taxon_concept_id,
    HSTORE(species_listing_id::TEXT, taxon_concept_id::TEXT) AS context,
    inclusion_taxon_concept_id,
    species_listing_id,
    change_type_id,
    effective_at,
    tree_distance AS context_tree_distance,
    timeline_position,
    CASE
     WHEN (
      -- there are listed populations
      ARRAY_UPPER(listed_geo_entities_ids, 1) IS NOT NULL
      -- and the taxon has its own distribution and does not occur in any of them
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND NOT listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
    )
    -- when all populations are excluded
    OR (
      ARRAY_UPPER(excluded_geo_entities_ids, 1) IS NOT NULL
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
    )
    THEN FALSE
    WHEN ARRAY_UPPER(excluded_taxon_concept_ids, 1) IS NOT NULL 
    -- if taxon or any of its ancestors is excluded from this listing
    AND excluded_taxon_concept_ids && ARRAY[
      affected_taxon_concept_id,
      taxon_concepts_mview.kingdom_id,
      taxon_concepts_mview.phylum_id,
      taxon_concepts_mview.class_id,
      taxon_concepts_mview.order_id,
      taxon_concepts_mview.family_id,
      taxon_concepts_mview.genus_id,
      taxon_concepts_mview.species_id
    ]
    THEN FALSE
    ELSE
    TRUE 
    END AS is_applicable
    FROM ' || all_listing_changes_mview || ' all_listing_changes_mview
    JOIN cms_tmp_taxon_concepts_mview taxon_concepts_mview
    ON all_listing_changes_mview.affected_taxon_concept_id = taxon_concepts_mview.id 
    WHERE all_listing_changes_mview.affected_taxon_concept_id = $1
    AND timeline_position = 1

    UNION

    SELECT hi.id,
    hi.designation_id,
    listing_changes_timeline.original_taxon_concept_id,
    hi.taxon_concept_id,
    -- BEGIN context
    CASE
    WHEN change_types.name = ''DELETION''
    AND hi.taxon_concept_id = hi.affected_taxon_concept_id
    THEN listing_changes_timeline.context - ARRAY[hi.species_listing_id::TEXT]
    WHEN change_types.name = ''DELETION''
    THEN listing_changes_timeline.context - HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    WHEN change_types.name = ''ADDITION''
    THEN listing_changes_timeline.context || HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    ELSE listing_changes_timeline.context
    END,
    -- END context
    hi.inclusion_taxon_concept_id,
    hi.species_listing_id,
    hi.change_type_id,
    hi.effective_at,
    CASE 
    WHEN hi.inclusion_taxon_concept_id IS NOT NULL
    OR hi.tree_distance < listing_changes_timeline.context_tree_distance
    THEN hi.tree_distance
    ELSE listing_changes_timeline.context_tree_distance
    END,
    hi.timeline_position,
    -- BEGIN is_applicable
    CASE
    WHEN (
      -- there are listed populations
      ARRAY_UPPER(hi.listed_geo_entities_ids, 1) IS NOT NULL
      -- and the taxon has its own distribution and does not occur in any of them
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND NOT hi.listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
    )
    -- when all populations are excluded
    OR (
      ARRAY_UPPER(hi.excluded_geo_entities_ids, 1) IS NOT NULL
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND hi.excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
    )
    THEN FALSE
    WHEN ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NOT NULL 
    -- if taxon or any of its ancestors is excluded from this listing
    AND hi.excluded_taxon_concept_ids && ARRAY[
      hi.affected_taxon_concept_id,
      taxon_concepts_mview.kingdom_id,
      taxon_concepts_mview.phylum_id,
      taxon_concepts_mview.class_id,
      taxon_concepts_mview.order_id,
      taxon_concepts_mview.family_id,
      taxon_concepts_mview.genus_id,
      taxon_concepts_mview.species_id
    ]
    THEN FALSE
    ELSE TRUE -- in CMS everything happily cascades
    END
    -- END is_applicable
    FROM ' || all_listing_changes_mview || ' hi
    JOIN listing_changes_timeline
    ON hi.designation_id = listing_changes_timeline.designation_id
    AND listing_changes_timeline.original_taxon_concept_id = hi.affected_taxon_concept_id
    AND listing_changes_timeline.timeline_position + 1 = hi.timeline_position
    JOIN change_types ON hi.change_type_id = change_types.id
    JOIN cms_tmp_taxon_concepts_mview taxon_concepts_mview
    ON hi.affected_taxon_concept_id = taxon_concepts_mview.id 
  )
  SELECT listing_changes_timeline.id
  FROM listing_changes_timeline
  WHERE is_applicable
  ORDER BY timeline_position';

  -- note to self: the reason to execute a string here rather than use an SQL
  -- function is that cms_all_listing_changes_mview does not exist at the time
  -- this function is defined.
  RETURN QUERY EXECUTE sql USING node_id;
END;
$_$;


--
-- Name: FUNCTION cms_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cms_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer) IS 'Returns applicable listing changes for a given node, including own and ancestors (following CMS cascading rules).';


--
-- Name: cms_leaf_listing(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cms_leaf_listing(node_id integer) RETURNS hstore
    LANGUAGE sql STABLE
    AS $_$
    SELECT hstore(
      'cms_listing',
      ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(
          SELECT * FROM UNNEST(
            ARRAY[
              taxon_concepts.listing -> 'cms_I',
              taxon_concepts.listing -> 'cms_II',
              taxon_concepts.listing -> 'cms_not_listed'
            ]
          ) s WHERE s IS NOT NULL
        ), '/'
      )
    )
    FROM taxon_concepts
    WHERE id = $1;
  $_$;


--
-- Name: copy_eu_suspensions_across_events(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_eu_suspensions_across_events(from_event_id integer, to_event_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      to_event events%ROWTYPE;
    BEGIN

    SELECT INTO to_event * FROM events WHERE id = to_event_id;

    -- copy eu_suspensions
    INSERT INTO eu_decisions (
      is_current, notes, internal_notes, taxon_concept_id, geo_entity_id,
      start_date, start_event_id, end_date, end_event_id, type, 
      conditions_apply, created_at, updated_at, eu_decision_type_id, 
      term_id, source_id, created_by_id, updated_by_id
    )
    SELECT true, source.notes, source.internal_notes, 
      source.taxon_concept_id, source.geo_entity_id, 
      to_event.effective_at, to_event_id, null, null, source.type, 
      source.conditions_apply, current_date, current_date, 
      source.eu_decision_type_id, source.term_id, source_id, 
      events.created_by_id, events.updated_by_id
    FROM eu_decisions source
    JOIN events
    ON events.id = to_event_id
    WHERE source.start_event_id = from_event_id  AND source.type = 'EuSuspension';

    UPDATE eu_decisions SET end_event_id = to_event.id 
    WHERE start_event_id = from_event_id AND type = 'EuSuspension';

    END;
  $$;


--
-- Name: FUNCTION copy_eu_suspensions_across_events(from_event_id integer, to_event_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION copy_eu_suspensions_across_events(from_event_id integer, to_event_id integer) IS 'Procedure to copy eu suspensions across two events.';


--
-- Name: copy_listing_changes_across_events(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_listing_changes_across_events(from_event_id integer, to_event_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      to_event events%ROWTYPE;
    BEGIN
    SELECT INTO to_event * FROM events WHERE id = to_event_id;
    WITH copied_annotations AS (
      -- copy regular annotations
      INSERT INTO annotations (
        symbol, parent_symbol,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        created_at, updated_at, original_id
      )
      SELECT symbol, parent_symbol,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        current_date, current_date, original.id
      FROM annotations original
      INNER JOIN listing_changes
        ON listing_changes.annotation_id = original.id
          AND listing_changes.event_id = from_event_id
      RETURNING id, original_id
    ), copied_hash_annotations AS (
      -- copy hash annotations
      INSERT INTO annotations (
        symbol, parent_symbol, event_id,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        created_at, updated_at, original_id
      )
      SELECT DISTINCT symbol, to_event.name, to_event_id,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        current_date, current_date, original.id
      FROM annotations original
      INNER JOIN listing_changes
        ON listing_changes.hash_annotation_id = original.id
          AND listing_changes.event_id = from_event_id
      RETURNING id, original_id
    ), copied_listing_changes AS (
      -- copy listing_changes
      INSERT INTO listing_changes (
        change_type_id, species_listing_id, annotation_id, hash_annotation_id,
        parent_id, taxon_concept_id, event_id, effective_at, is_current,
        created_at, updated_at, original_id, created_by_id, updated_by_id
      )
      SELECT original.change_type_id, original.species_listing_id,
        copied_annotations.id, copied_hash_annotations.id, original.parent_id,
        original.taxon_concept_id, to_event.id, to_event.effective_at, to_event.is_current,
        current_date, current_date, original.id,
        events.created_by_id, events.updated_by_id
      FROM listing_changes original
      LEFT JOIN copied_annotations
        ON original.annotation_id = copied_annotations.original_id
      LEFT JOIN copied_hash_annotations
        ON original.hash_annotation_id = copied_hash_annotations.original_id
      JOIN events
        ON events.id = to_event_id
      WHERE original.event_id = from_event_id
      RETURNING id, original_id
    )
    INSERT INTO listing_distributions (
      listing_change_id, geo_entity_id, is_party, created_at, updated_at
    )
    SELECT copied_listing_changes.id, original.geo_entity_id, original.is_party,
      current_date, current_date
    FROM listing_distributions original
    INNER JOIN copied_listing_changes
      ON copied_listing_changes.original_id = original.listing_change_id;
    END;
  $$;


--
-- Name: FUNCTION copy_listing_changes_across_events(from_event_id integer, to_event_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION copy_listing_changes_across_events(from_event_id integer, to_event_id integer) IS 'Procedure to copy listing changes across two events.';


--
-- Name: copy_quotas_across_years(integer, date, date, date, integer[], integer[], integer[], integer[], character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_quotas_across_years(from_year integer, new_start_date date, new_end_date date, new_publication_date date, excluded_taxon_concepts_ids integer[], included_taxon_concepts_ids integer[], excluded_geo_entities_ids integer[], included_geo_entities_ids integer[], from_text character varying, to_text character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
   included_taxon_concepts INTEGER[];
   excluded_taxon_concepts INTEGER[];
   included_geo_entities INTEGER[];
   excluded_geo_entities INTEGER[];
   cites_taxonomy_id INTEGER;
   updated_rows INTEGER;
BEGIN

    SELECT id into cites_taxonomy_id FROM taxonomies WHERE name = 'CITES_EU';

    -- fetch included_taxon_concepts
    WITH RECURSIVE self_and_descendants(id, full_name) AS (
      SELECT id, full_name FROM taxon_concepts
      WHERE included_taxon_concepts_ids @> ARRAY[id] AND taxonomy_id = cites_taxonomy_id

      UNION

      SELECT hi.id, hi.full_name FROM taxon_concepts hi
      JOIN self_and_descendants d ON d.id = hi.parent_id
      WHERE  hi.taxonomy_id = cites_taxonomy_id
    )
    SELECT array_agg(id) INTO included_taxon_concepts FROM self_and_descendants;

    -- fetch excluded_taxon_concepts
    WITH RECURSIVE self_and_descendants(id, full_name) AS (
      SELECT id, full_name FROM taxon_concepts
      WHERE excluded_taxon_concepts_ids @> ARRAY[id] AND taxonomy_id = cites_taxonomy_id

      UNION

      SELECT hi.id, hi.full_name FROM taxon_concepts hi
      JOIN self_and_descendants d ON d.id = hi.parent_id
    )
    SELECT array_agg(id) INTO excluded_taxon_concepts FROM self_and_descendants;

    -- fetch included geo entities
    SELECT array_agg(matches.id) INTO included_geo_entities
    FROM (
      SELECT geo_entities.id FROM geo_entities
      WHERE included_geo_entities_ids @> ARRAY[id]
      UNION
      SELECT geo_entities.id FROM geo_entities
      INNER JOIN geo_relationships ON geo_relationships.other_geo_entity_id = geo_entities.id
        AND included_geo_entities_ids @> ARRAY[geo_relationships.geo_entity_id]
      INNER JOIN geo_relationship_types ON geo_relationship_types.id = geo_relationships.geo_relationship_type_id
        AND geo_relationship_types.name = 'CONTAINS'
    ) AS matches;

    -- fetch excluded geo entities
    SELECT array_agg(matches.id) INTO excluded_geo_entities
    FROM (
      SELECT geo_entities.id FROM geo_entities
      WHERE excluded_geo_entities_ids @> ARRAY[id]
      UNION
      SELECT geo_entities.id FROM geo_entities
      INNER JOIN geo_relationships ON geo_relationships.other_geo_entity_id = geo_entities.id
        AND excluded_geo_entities_ids @> ARRAY[geo_relationships.geo_entity_id]
      INNER JOIN geo_relationship_types ON geo_relationship_types.id = geo_relationships.geo_relationship_type_id
        AND geo_relationship_types.name = 'CONTAINS'
    ) AS matches;

    WITH original_current_quotas AS (
      SELECT *
      FROM trade_restrictions
      WHERE type = 'Quota' AND EXTRACT(year FROM start_date) =  from_year AND is_current = true
      AND (ARRAY_LENGTH(excluded_taxon_concepts, 1) IS NULL OR NOT excluded_taxon_concepts @> ARRAY[taxon_concept_id])
      AND (ARRAY_LENGTH(included_taxon_concepts, 1) IS NULL OR included_taxon_concepts @> ARRAY[taxon_concept_id])	
      AND (ARRAY_LENGTH(excluded_geo_entities, 1) IS NULL OR NOT excluded_geo_entities @> ARRAY[geo_entity_id])
      AND (ARRAY_LENGTH(included_geo_entities, 1) IS NULL OR included_geo_entities  @> ARRAY[geo_entity_id])
    ), original_terms AS (
      SELECT quota_terms.*
      FROM trade_restriction_terms quota_terms
      JOIN original_current_quotas quotas
      ON quota_terms.trade_restriction_id = quotas.id
    ), original_sources AS (
      SELECT quota_sources.*
      FROM trade_restriction_sources quota_sources
      JOIN original_current_quotas quotas
      ON quota_sources.trade_restriction_id = quotas.id
    ), updated_quotas AS (
      UPDATE trade_restrictions
      SET is_current = false
      FROM original_current_quotas
      WHERE trade_restrictions.id = original_current_quotas.id
    ), inserted_quotas AS (
      INSERT INTO trade_restrictions(type, is_current, start_date, end_date, geo_entity_id, quota,
      publication_date, notes, unit_id, taxon_concept_id, public_display, url, created_at, updated_at,
      excluded_taxon_concepts_ids, original_id)
      SELECT 'Quota', is_current, new_start_date, new_end_date, geo_entity_id, quota,
      new_publication_date,
      CASE
        WHEN LENGTH(from_text) = 0
        THEN notes
      ELSE
        REPLACE(notes, from_text, to_text)
      END, unit_id, taxon_concept_id, public_display, url,
      NOW(), NOW(), trade_restrictions.excluded_taxon_concepts_ids,
      trade_restrictions.id
      FROM original_current_quotas AS trade_restrictions
      RETURNING *
    ), inserted_terms AS (
      INSERT INTO trade_restriction_terms (
        trade_restriction_id, term_id, created_at, updated_at
      )
      SELECT inserted_quotas.id, original_terms.term_id, NOW(), NOW()
      FROM original_terms
      JOIN inserted_quotas
      ON inserted_quotas.original_id = original_terms.trade_restriction_id
    ), inserted_sources AS (
      INSERT INTO trade_restriction_sources (
        trade_restriction_id, source_id, created_at, updated_at
      )
      SELECT inserted_quotas.id, original_sources.source_id, NOW(), NOW()
      FROM original_sources
      JOIN inserted_quotas
      ON inserted_quotas.original_id = original_sources.trade_restriction_id
    )
    SELECT COUNT(*) INTO updated_rows
    FROM inserted_quotas;

    RAISE INFO '[%] Copied % quotas', 'trade_transactions', updated_rows;
  END;
$$;


--
-- Name: FUNCTION copy_quotas_across_years(from_year integer, new_start_date date, new_end_date date, new_publication_date date, excluded_taxon_concepts_ids integer[], included_taxon_concepts_ids integer[], excluded_geo_entities_ids integer[], included_geo_entities_ids integer[], from_text character varying, to_text character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION copy_quotas_across_years(from_year integer, new_start_date date, new_end_date date, new_publication_date date, excluded_taxon_concepts_ids integer[], included_taxon_concepts_ids integer[], excluded_geo_entities_ids integer[], included_geo_entities_ids integer[], from_text character varying, to_text character varying) IS 'Procedure to copy quotas across two years with some filtering parameters.';


--
-- Name: copy_quotas_across_years(integer, date, date, date, integer[], integer[], integer[], integer[], character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_quotas_across_years(from_year integer, new_start_date date, new_end_date date, new_publication_date date, excluded_taxon_concepts_ids integer[], included_taxon_concepts_ids integer[], excluded_geo_entities_ids integer[], included_geo_entities_ids integer[], from_text character varying, to_text character varying, current_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
   included_taxon_concepts INTEGER[];
   excluded_taxon_concepts INTEGER[];
   included_geo_entities INTEGER[];
   excluded_geo_entities INTEGER[];
   cites_taxonomy_id INTEGER;
   updated_rows INTEGER;
BEGIN

    SELECT id into cites_taxonomy_id FROM taxonomies WHERE name = 'CITES_EU';

    -- fetch included_taxon_concepts
    WITH RECURSIVE self_and_descendants(id, full_name) AS (
      SELECT id, full_name FROM taxon_concepts
      WHERE included_taxon_concepts_ids @> ARRAY[id] AND taxonomy_id = cites_taxonomy_id

      UNION

      SELECT hi.id, hi.full_name FROM taxon_concepts hi
      JOIN self_and_descendants d ON d.id = hi.parent_id
      WHERE  hi.taxonomy_id = cites_taxonomy_id
    )
    SELECT array_agg(id) INTO included_taxon_concepts FROM self_and_descendants;

    -- fetch excluded_taxon_concepts
    WITH RECURSIVE self_and_descendants(id, full_name) AS (
      SELECT id, full_name FROM taxon_concepts
      WHERE excluded_taxon_concepts_ids @> ARRAY[id] AND taxonomy_id = cites_taxonomy_id

      UNION

      SELECT hi.id, hi.full_name FROM taxon_concepts hi
      JOIN self_and_descendants d ON d.id = hi.parent_id
    )
    SELECT array_agg(id) INTO excluded_taxon_concepts FROM self_and_descendants;

    -- fetch included geo entities
    SELECT array_agg(matches.id) INTO included_geo_entities
    FROM (
      SELECT geo_entities.id FROM geo_entities
      WHERE included_geo_entities_ids @> ARRAY[id]
      UNION
      SELECT geo_entities.id FROM geo_entities
      INNER JOIN geo_relationships ON geo_relationships.other_geo_entity_id = geo_entities.id
        AND included_geo_entities_ids @> ARRAY[geo_relationships.geo_entity_id]
      INNER JOIN geo_relationship_types ON geo_relationship_types.id = geo_relationships.geo_relationship_type_id
        AND geo_relationship_types.name = 'CONTAINS'
    ) AS matches;

    -- fetch excluded geo entities
    SELECT array_agg(matches.id) INTO excluded_geo_entities
    FROM (
      SELECT geo_entities.id FROM geo_entities
      WHERE excluded_geo_entities_ids @> ARRAY[id]
      UNION
      SELECT geo_entities.id FROM geo_entities
      INNER JOIN geo_relationships ON geo_relationships.other_geo_entity_id = geo_entities.id
        AND excluded_geo_entities_ids @> ARRAY[geo_relationships.geo_entity_id]
      INNER JOIN geo_relationship_types ON geo_relationship_types.id = geo_relationships.geo_relationship_type_id
        AND geo_relationship_types.name = 'CONTAINS'
    ) AS matches;

    WITH original_current_quotas AS (
      SELECT *
      FROM trade_restrictions
      WHERE type = 'Quota' AND EXTRACT(year FROM start_date) =  from_year AND is_current = true
      AND (ARRAY_LENGTH(excluded_taxon_concepts, 1) IS NULL OR NOT excluded_taxon_concepts @> ARRAY[taxon_concept_id])
      AND (ARRAY_LENGTH(included_taxon_concepts, 1) IS NULL OR included_taxon_concepts @> ARRAY[taxon_concept_id])	
      AND (ARRAY_LENGTH(excluded_geo_entities, 1) IS NULL OR NOT excluded_geo_entities @> ARRAY[geo_entity_id])
      AND (ARRAY_LENGTH(included_geo_entities, 1) IS NULL OR included_geo_entities  @> ARRAY[geo_entity_id])
    ), original_terms AS (
      SELECT quota_terms.*
      FROM trade_restriction_terms quota_terms
      JOIN original_current_quotas quotas
      ON quota_terms.trade_restriction_id = quotas.id
    ), original_sources AS (
      SELECT quota_sources.*
      FROM trade_restriction_sources quota_sources
      JOIN original_current_quotas quotas
      ON quota_sources.trade_restriction_id = quotas.id
    ), updated_quotas AS (
      UPDATE trade_restrictions
      SET is_current = false
      FROM original_current_quotas
      WHERE trade_restrictions.id = original_current_quotas.id
    ), inserted_quotas AS (
      INSERT INTO trade_restrictions(created_by_id, updated_by_id, type, is_current, start_date, 
      end_date, geo_entity_id, quota, publication_date, notes, unit_id, taxon_concept_id, 
      public_display, url, created_at, updated_at, excluded_taxon_concepts_ids, original_id)
      SELECT current_user_id, current_user_id, 'Quota', is_current, new_start_date, new_end_date, geo_entity_id, 
      quota, new_publication_date,
      CASE
        WHEN LENGTH(from_text) = 0
        THEN notes
      ELSE
        REPLACE(notes, from_text, to_text)
      END, unit_id, taxon_concept_id, public_display, url,
      NOW(), NOW(), trade_restrictions.excluded_taxon_concepts_ids,
      trade_restrictions.id
      FROM original_current_quotas AS trade_restrictions
      RETURNING *
    ), inserted_terms AS (
      INSERT INTO trade_restriction_terms (
        trade_restriction_id, term_id, created_at, updated_at
      )
      SELECT inserted_quotas.id, original_terms.term_id, NOW(), NOW()
      FROM original_terms
      JOIN inserted_quotas
      ON inserted_quotas.original_id = original_terms.trade_restriction_id
    ), inserted_sources AS (
      INSERT INTO trade_restriction_sources (
        trade_restriction_id, source_id, created_at, updated_at
      )
      SELECT inserted_quotas.id, original_sources.source_id, NOW(), NOW()
      FROM original_sources
      JOIN inserted_quotas
      ON inserted_quotas.original_id = original_sources.trade_restriction_id
    )
    SELECT COUNT(*) INTO updated_rows
    FROM inserted_quotas;

    RAISE INFO '[%] Copied % quotas', 'trade_transactions', updated_rows;
  END;
$$;


--
-- Name: FUNCTION copy_quotas_across_years(from_year integer, new_start_date date, new_end_date date, new_publication_date date, excluded_taxon_concepts_ids integer[], included_taxon_concepts_ids integer[], excluded_geo_entities_ids integer[], included_geo_entities_ids integer[], from_text character varying, to_text character varying, current_user_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION copy_quotas_across_years(from_year integer, new_start_date date, new_end_date date, new_publication_date date, excluded_taxon_concepts_ids integer[], included_taxon_concepts_ids integer[], excluded_geo_entities_ids integer[], included_geo_entities_ids integer[], from_text character varying, to_text character varying, current_user_id integer) IS 'Procedure to copy quotas across two years with some filtering parameters.';


--
-- Name: copy_transactions_from_sandbox_to_shipments(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_transactions_from_sandbox_to_shipments(annual_report_upload_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  aru trade_annual_report_uploads%ROWTYPE;
  table_name TEXT;
  cites_taxonomy_id INTEGER;
  reported_by_exporter BOOLEAN;
  inserted_rows INTEGER;
  inserted_shipments INTEGER;
  total_shipments INTEGER;
  sql TEXT;
  permit_type TEXT;
BEGIN
  SELECT * INTO aru FROM trade_annual_report_uploads WHERE id = annual_report_upload_id;
  IF NOT FOUND THEN
    RAISE NOTICE '[%] Annual report upload not found.', table_name;
    RETURN -1;
  END IF;
  IF aru.point_of_view = 'E' THEN
    reported_by_exporter := TRUE;
  ELSE
    reported_by_exporter := FALSE;
  END IF;
  SELECT id INTO cites_taxonomy_id FROM taxonomies WHERE name = 'CITES_EU';
  IF NOT FOUND THEN
    RAISE NOTICE '[%] Taxonomy not found.', table_name;
    RETURN -1;
  END IF;
  table_name := 'trade_sandbox_' || annual_report_upload_id;
  EXECUTE 'SELECT COUNT(*) FROM ' || table_name INTO total_shipments;
  RAISE INFO '[%] Copying % rows from %', table_name, total_shipments, table_name;


  sql := '
    WITH split_permits AS (
      SELECT id,
      SQUISH(regexp_split_to_table(export_permit, ''[:;,]'')) AS permit
      FROM '|| table_name || '
      UNION
      SELECT id,
      SQUISH(regexp_split_to_table(import_permit, ''[:;,]'')) AS permit
      FROM '|| table_name || '
      UNION
      SELECT id,
      SQUISH(regexp_split_to_table(origin_permit, ''[:;,]'')) AS permit
      FROM '|| table_name || '
    ), permits_to_be_inserted (number) AS (
      SELECT DISTINCT permit FROM split_permits WHERE permit IS NOT NULL
      EXCEPT
      SELECT number FROM trade_permits
    )
    INSERT INTO trade_permits(number, created_at, updated_at)
    SELECT number, current_timestamp, current_timestamp
    FROM permits_to_be_inserted';

  EXECUTE sql;

  GET DIAGNOSTICS inserted_rows = ROW_COUNT;
  RAISE INFO '[%] Inserted % permits', table_name, inserted_rows;

  sql := '
    CREATE TEMP TABLE ' || table_name || '_for_submit AS
    WITH inserted_shipments AS (
      INSERT INTO trade_shipments (
        source_id,
        unit_id,
        purpose_id,
        term_id,
        quantity,
        appendix,
        trade_annual_report_upload_id,
        exporter_id,
        importer_id,
        country_of_origin_id,
        reported_by_exporter,
        taxon_concept_id,
        reported_taxon_concept_id,
        year,
        sandbox_id,
        created_at,
        updated_at,
        created_by_id,
        updated_by_id
      )
      SELECT
        sources.id AS source_id,
        units.id AS unit_id,
        purposes.id AS purpose_id,
        terms.id AS term_id,
        sandbox_table.quantity::NUMERIC AS quantity,
        sandbox_table.appendix,' ||
        aru.id || 'AS trade_annual_report_upload_id,
        exporters.id AS exporter_id,
        importers.id AS importer_id,
        origins.id AS country_of_origin_id,' ||
        reported_by_exporter || ' AS reported_by_exporter,
        taxon_concept_id,
        reported_taxon_concept_id,
        sandbox_table.year::INTEGER AS year,
        sandbox_table.id AS sandbox_id,
        current_timestamp,
        current_timestamp, ' ||
        aru.created_by_id || ', ' ||
        aru.updated_by_id || '
      FROM '|| table_name || ' sandbox_table';

    IF reported_by_exporter THEN
      sql := sql ||
      '
      JOIN geo_entities AS exporters ON
        exporters.id = ' || aru.trading_country_id ||
      '
      JOIN geo_entities AS importers ON
        importers.iso_code2 = sandbox_table.trading_partner';
    ELSE
      sql := sql ||
      '
      JOIN geo_entities AS exporters ON
        exporters.iso_code2 = sandbox_table.trading_partner
      JOIN geo_entities AS importers ON
        importers.id = ' || aru.trading_country_id;
    END IF;
    sql := sql ||
      '
      JOIN trade_codes AS terms ON sandbox_table.term_code = terms.code
        AND terms.type = ''Term''
      LEFT JOIN trade_codes AS sources ON sandbox_table.source_code = sources.code
        AND sources.type = ''Source''
      LEFT JOIN trade_codes AS units ON sandbox_table.unit_code = units.code
        AND units.type = ''Unit''
      LEFT JOIN trade_codes AS purposes ON sandbox_table.purpose_code = purposes.code
        AND purposes.type = ''Purpose''
      LEFT JOIN geo_entities AS origins ON origins.iso_code2 = sandbox_table.country_of_origin
      RETURNING *
    ) SELECT * FROM inserted_shipments';

  EXECUTE sql;

  GET DIAGNOSTICS inserted_shipments = ROW_COUNT;
  RAISE INFO '[%] Inserted % shipments out of %', table_name, inserted_shipments, total_shipments;
  IF inserted_shipments < total_shipments THEN
    RETURN -1;
  END IF;

  FOREACH permit_type IN ARRAY ARRAY['export', 'import', 'origin'] LOOP

    sql := 'WITH split_permits AS (
      SELECT id, SQUISH(regexp_split_to_table(' || permit_type || '_permit, ''[:;,]'')) AS permit
      FROM '|| table_name || '
    ), shipment_permits AS (
      SELECT DISTINCT ON (1,2)
        shipments_for_submit.id AS trade_shipment_id,
        trade_permits.id AS trade_permit_id,
        trade_permits.number
      FROM '|| table_name || '_for_submit shipments_for_submit
      INNER JOIN split_permits
        ON split_permits.id = shipments_for_submit.sandbox_id
      INNER JOIN trade_permits
        ON trade_permits.number = split_permits.permit
    ), agg_shipment_permits AS (
      SELECT trade_shipment_id,
      ARRAY_AGG(trade_permit_id) AS permits_ids,
      ARRAY_TO_STRING(ARRAY_AGG(number), '';'') AS permit_number
      FROM shipment_permits
      GROUP BY trade_shipment_id
    )
    UPDATE trade_shipments
    SET ' || permit_type || '_permit_number = sp.permit_number,
    ' || permit_type || '_permits_ids = sp.permits_ids
    FROM agg_shipment_permits sp
    WHERE sp.trade_shipment_id = trade_shipments.id;
    ';

    EXECUTE sql;

    GET DIAGNOSTICS inserted_rows = ROW_COUNT;
    RAISE INFO '[%] Inserted % shipment % permits', table_name, inserted_rows, permit_type;

  END LOOP;

  sql := 'UPDATE trade_shipments SET sandbox_id = NULL
  WHERE trade_shipments.trade_annual_report_upload_id = ' || aru.id;
  EXECUTE sql;
  RETURN inserted_shipments;
END;
$$;


--
-- Name: FUNCTION copy_transactions_from_sandbox_to_shipments(annual_report_upload_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION copy_transactions_from_sandbox_to_shipments(annual_report_upload_id integer) IS 'Procedure to copy transactions from sandbox to shipments. Returns the number of rows copied if success, 0 if failure.';


--
-- Name: create_trade_sandbox_view(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_trade_sandbox_view(target_table_name text, idx integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    execute 'CREATE VIEW ' || target_table_name || '_view AS
      SELECT aru.point_of_view,
      CASE
        WHEN aru.point_of_view = ''E''
        THEN geo_entities.iso_code2
        ELSE trading_partner
      END AS exporter,
      CASE
        WHEN aru.point_of_view = ''E''
        THEN trading_partner
        ELSE geo_entities.iso_code2 
      END AS importer,
      taxon_concepts.full_name AS accepted_taxon_name,
      taxon_concepts.data->''rank_name'' AS rank,
      taxon_concepts.rank_id,
      ' || target_table_name || '.*
      FROM ' || target_table_name || '
      JOIN trade_annual_report_uploads aru ON aru.id = ' || idx || '
      JOIN geo_entities ON geo_entities.id = aru.trading_country_id
      LEFT JOIN taxon_concepts ON taxon_concept_id = taxon_concepts.id';
    RETURN;
  END;
  $$;


--
-- Name: create_trade_sandbox_views(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_trade_sandbox_views() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    current_table_name TEXT;
    aru_id INT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'trade_sandbox%'
      AND table_name != 'trade_sandbox_template'
      AND table_type != 'VIEW'
    LOOP
      aru_id := SUBSTRING(current_table_name, E'trade_sandbox_(\\\\d+)')::INT;
      IF aru_id IS NULL THEN
  RAISE WARNING 'Unable to determine annual report upload id from %', current_table_name;
      ELSE
  PERFORM create_trade_sandbox_view(current_table_name, aru_id);
      END IF;
    END LOOP;
    RETURN;
  END;
  $$;


--
-- Name: drop_eu_lc_mviews(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION drop_eu_lc_mviews() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    current_table_name TEXT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'eu_%_listing_changes_mview'
      AND table_type != 'VIEW'
    LOOP
      EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;


--
-- Name: drop_import_tables(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION drop_import_tables() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    current_table_name TEXT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE '%_import'
      AND table_type != 'VIEW'
    LOOP
      EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;


--
-- Name: drop_trade_sandbox_views(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION drop_trade_sandbox_views() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    current_view_name TEXT;
  BEGIN
    FOR current_view_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'trade_sandbox%_view'
      AND table_type = 'VIEW'
    LOOP
      EXECUTE 'DROP VIEW IF EXISTS ' || current_view_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;


--
-- Name: drop_trade_sandboxes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION drop_trade_sandboxes() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    current_table_name TEXT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'trade_sandbox%'
      AND table_name != 'trade_sandbox_template'
      AND table_type != 'VIEW'
    LOOP
      EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;


--
-- Name: FUNCTION drop_trade_sandboxes(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION drop_trade_sandboxes() IS '
Drops all trade_sandbox_n tables. Used in specs only, you need to know what
you''re doing. If you''re looking to drop all sandboxes in the live system,
use the rake db:drop_sandboxes task instead.';


--
-- Name: eu_aggregate_children_listing(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION eu_aggregate_children_listing(node_id integer) RETURNS hstore
    LANGUAGE sql STABLE
    AS $_$
    WITH aggregated_children_listing AS (
      SELECT
      -- this to be used in the timelines: if there are explicitly listed
      -- descendants, the timeline might differ from the current listing
      -- and a note should be displayed to inform the user
      hstore('eu_listed_descendants', BOOL_OR(
        (listing -> 'eu_status_original')::BOOLEAN
        OR (listing -> 'eu_listed_descendants')::BOOLEAN
      )::VARCHAR) ||
      hstore('eu_A', MAX((listing -> 'eu_A')::VARCHAR)) ||
      hstore('eu_B', MAX((listing -> 'eu_B')::VARCHAR)) ||
      hstore('eu_C', MAX((listing -> 'eu_C')::VARCHAR)) ||
      hstore('eu_D', MAX((listing -> 'eu_D')::VARCHAR)) ||
      hstore('eu_NC', MAX((listing -> 'eu_not_listed')::VARCHAR)) ||
      hstore('eu_listing', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[
            (MAX(listing -> 'eu_A')::VARCHAR),
            (MAX(listing -> 'eu_B')::VARCHAR),
            (MAX(listing -> 'eu_C')::VARCHAR),
            (MAX(listing -> 'eu_D')::VARCHAR),
            (MAX(listing -> 'eu_not_listed')::VARCHAR)
          ]) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM taxon_concepts
      WHERE
        -- aggregate children's listings
        parent_id = $1
        -- as well as parent if they're explicitly listed
        OR (
          id = $1
          AND (listing->'eu_status_original')::BOOLEAN
        )
        -- as well as parent if they are species
        -- the assumption being they will have subspecies
        -- which are not listed in their own right and
        -- should therefore inherit the cascaded listing
        -- if one exists
        -- this should fix Lutrinae species, which should be I/II
        -- even though subspecies in the db are on I
        OR (
          id = $1
          AND data->'rank_name' = 'SPECIES'
        )
    )
    SELECT listing
    FROM aggregated_children_listing;
  $_$;


--
-- Name: eu_applicable_listing_changes_for_node(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION eu_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer) RETURNS SETOF integer
    LANGUAGE sql STABLE STRICT
    AS $_$
  SELECT * FROM cites_eu_applicable_listing_changes_for_node($1, $2);
$_$;


--
-- Name: FUNCTION eu_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION eu_applicable_listing_changes_for_node(all_listing_changes_mview text, node_id integer) IS 'Returns applicable listing changes for a given node, including own and ancestors (following EU cascading rules).';


--
-- Name: eu_leaf_listing(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION eu_leaf_listing(node_id integer) RETURNS hstore
    LANGUAGE sql STABLE
    AS $_$
    SELECT hstore(
      'eu_listing',
      ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(
          SELECT * FROM UNNEST(
            ARRAY[
              taxon_concepts.listing -> 'eu_A',
              taxon_concepts.listing -> 'eu_B',
              taxon_concepts.listing -> 'eu_C',
              taxon_concepts.listing -> 'eu_D',
              taxon_concepts.listing -> 'eu_not_listed'
            ]
          ) s WHERE s IS NOT NULL
        ), '/'
      )
    )
    FROM taxon_concepts
    WHERE id = $1;
  $_$;


--
-- Name: fn_array_agg_notnull(anyarray, anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fn_array_agg_notnull(a anyarray, b anyelement) RETURNS anyarray
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN

    IF b IS NOT NULL THEN
        a := array_append(a, b);
    END IF;

    RETURN a;

END;
$$;


--
-- Name: full_name(character varying, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION full_name(rank_name character varying, ancestors hstore) RETURNS character varying
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE
      WHEN $1 = 'SPECIES' THEN
        -- now create a binomen for full name
        CAST($2 -> 'genus_name' AS VARCHAR) || ' ' ||
        LOWER(CAST($2 -> 'species_name' AS VARCHAR))
      WHEN $1 = 'SUBSPECIES' THEN
        -- now create a trinomen for full name
        CAST($2 -> 'genus_name' AS VARCHAR) || ' ' ||
        LOWER(CAST($2 -> 'species_name' AS VARCHAR)) || ' ' ||
        LOWER(CAST($2 -> 'subspecies_name' AS VARCHAR))
      WHEN $1 = 'VARIETY' THEN
        -- now create a trinomen for full name
        CAST($2 -> 'genus_name' AS VARCHAR) || ' ' ||
        LOWER(CAST($2 -> 'species_name' AS VARCHAR)) || ' var. ' ||
        LOWER(CAST($2 -> 'variety_name' AS VARCHAR))      
      ELSE $2 -> LOWER($1 || '_name')
    END;
  $_$;


--
-- Name: full_name_with_spp(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION full_name_with_spp(rank_name character varying, full_name character varying) RETURNS character varying
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE
      WHEN $1 IN ('ORDER', 'FAMILY', 'SUBFAMILY', 'GENUS')
      THEN $2 || ' spp.'
      ELSE $2
    END;
  $_$;


--
-- Name: FUNCTION full_name_with_spp(rank_name character varying, full_name character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION full_name_with_spp(rank_name character varying, full_name character varying) IS 'Returns full name with ssp where applicable depending on rank.';


--
-- Name: higher_or_equal_ranks_names(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION higher_or_equal_ranks_names(in_rank_name character varying) RETURNS text[]
    LANGUAGE sql IMMUTABLE
    AS $_$
    WITH ranks_in_order(row_no, rank_name) AS (
      SELECT ROW_NUMBER() OVER(), *
      FROM UNNEST(ARRAY[
      'VARIETY', 'SUBSPECIES', 'SPECIES', 'GENUS', 'SUBFAMILY',
      'FAMILY', 'ORDER', 'CLASS', 'PHYLUM', 'KINGDOM'
      ])
    )
    SELECT ARRAY_AGG(rank_name) FROM ranks_in_order
    WHERE row_no >= (SELECT row_no FROM ranks_in_order WHERE rank_name = $1);
  $_$;


--
-- Name: FUNCTION higher_or_equal_ranks_names(in_rank_name character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION higher_or_equal_ranks_names(in_rank_name character varying) IS 'Returns an array of rank names above the given rank (sorted lowest first).';


--
-- Name: isnumeric(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION isnumeric(text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
DECLARE x NUMERIC;
BEGIN
    x = $1::NUMERIC;
    RETURN TRUE;
EXCEPTION WHEN others THEN
    RETURN FALSE;
END;
$_$;


--
-- Name: listing_changes_mview_name(text, text, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION listing_changes_mview_name(prefix text, designation text, events_ids integer[]) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE WHEN $1 IS NULL THEN '' ELSE $1 || '_' END ||
    $2 ||
    CASE
      WHEN $3 IS NOT NULL
      THEN '_' || ARRAY_TO_STRING($3, '_')
      ELSE ''
    END || '_listing_changes_mview';
  $_$;


--
-- Name: rebuild_ancestor_cites_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_cites_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_ancestor_cites_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_ancestor_cites_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_ancestor_cites_listing() IS 'Procedure to rebuild CITES ancestor listings in taxon_concepts.';


--
-- Name: rebuild_ancestor_cites_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_cites_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      ancestor_node_ids INTEGER[];
      tmp_node_id int;
    BEGIN
      IF node_id IS NULL THEN
        FOR tmp_node_id IN SELECT taxon_concepts.id FROM taxon_concepts
          JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
          AND taxonomies.name = 'CITES_EU'
          WHERE parent_id IS NULL
        LOOP
          PERFORM rebuild_ancestor_cites_listing_for_node(tmp_node_id);
        END LOOP;
        RETURN;
      END IF;
      PERFORM rebuild_ancestor_cites_listing_recursively_for_node(node_id);
      -- if we're not starting from root, we need to update ancestors
      -- up till root
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
      FOREACH tmp_node_id IN ARRAY ancestor_node_ids
      LOOP
        UPDATE taxon_concepts
        SET listing  = listing || cites_aggregate_children_listing(tmp_node_id)
        WHERE id = tmp_node_id;
      END LOOP;
    END;
  $$;


--
-- Name: rebuild_ancestor_cites_listing_recursively_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_cites_listing_recursively_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      children_node_ids INTEGER[];
      tmp_node_id INT;
    BEGIN
      SELECT ARRAY_AGG_NOTNULL(id) INTO children_node_ids
      FROM taxon_concepts
      WHERE parent_id = node_id;
      -- if there are children, rebuild their aggregated listing first
      FOREACH tmp_node_id IN ARRAY children_node_ids
      LOOP
        PERFORM rebuild_ancestor_cites_listing_recursively_for_node(tmp_node_id);
      END LOOP;

      -- update this node's aggregated listing
      IF ARRAY_UPPER(children_node_ids, 1) IS NULL THEN
        UPDATE taxon_concepts
        SET listing = listing || cites_leaf_listing(node_id)
        WHERE id = node_id;
      ELSE
        UPDATE taxon_concepts
        SET listing = listing || cites_aggregate_children_listing(node_id)
        WHERE id = node_id;
      END IF;
    END;
  $$;


--
-- Name: rebuild_ancestor_cms_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_cms_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_ancestor_cms_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_ancestor_cms_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_ancestor_cms_listing() IS 'Procedure to rebuild CITES ancestor listings in taxon_concepts.';


--
-- Name: rebuild_ancestor_cms_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_cms_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      ancestor_node_ids INTEGER[];
      tmp_node_id int;
    BEGIN
      IF node_id IS NULL THEN
        FOR tmp_node_id IN SELECT taxon_concepts.id FROM taxon_concepts
          JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
          AND taxonomies.name = 'CMS'
          WHERE parent_id IS NULL
        LOOP
          PERFORM rebuild_ancestor_cms_listing_for_node(tmp_node_id);
        END LOOP;
        RETURN;
      END IF;
      PERFORM rebuild_ancestor_cms_listing_recursively_for_node(node_id);
      -- if we're not starting from root, we need to update ancestors
      -- up till root
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
      FOREACH tmp_node_id IN ARRAY ancestor_node_ids
      LOOP
        UPDATE taxon_concepts
        SET listing  = listing || cms_aggregate_children_listing(tmp_node_id)
        WHERE id = tmp_node_id;
      END LOOP;
    END;
  $$;


--
-- Name: rebuild_ancestor_cms_listing_recursively_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_cms_listing_recursively_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      children_node_ids INTEGER[];
      tmp_node_id INT;
    BEGIN
      SELECT ARRAY_AGG_NOTNULL(id) INTO children_node_ids
      FROM taxon_concepts
      WHERE parent_id = node_id;
      -- if there are children, rebuild their aggregated listing first
      FOREACH tmp_node_id IN ARRAY children_node_ids
      LOOP
        PERFORM rebuild_ancestor_cms_listing_recursively_for_node(tmp_node_id);
      END LOOP;

      -- update this node's aggregated listing
      IF ARRAY_UPPER(children_node_ids, 1) IS NULL THEN
        UPDATE taxon_concepts
        SET listing = listing || cms_leaf_listing(node_id)
        WHERE id = node_id;
      ELSE
        UPDATE taxon_concepts
        SET listing = listing || cms_aggregate_children_listing(node_id)
        WHERE id = node_id;
      END IF;
    END;
  $$;


--
-- Name: rebuild_ancestor_eu_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_eu_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_ancestor_eu_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_ancestor_eu_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_ancestor_eu_listing() IS 'Procedure to rebuild EU ancestor listings in taxon_concepts.';


--
-- Name: rebuild_ancestor_eu_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_eu_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      ancestor_node_ids INTEGER[];
      tmp_node_id int;
    BEGIN
      IF node_id IS NULL THEN
        FOR tmp_node_id IN SELECT taxon_concepts.id FROM taxon_concepts
          JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
          AND taxonomies.name = 'CITES_EU'
          WHERE parent_id IS NULL
        LOOP
          PERFORM rebuild_ancestor_eu_listing_for_node(tmp_node_id);
        END LOOP;
        RETURN;
      END IF;
      PERFORM rebuild_ancestor_eu_listing_recursively_for_node(node_id);
      -- if we're not starting from root, we need to update ancestors
      -- up till root
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
      FOREACH tmp_node_id IN ARRAY ancestor_node_ids
      LOOP
        UPDATE taxon_concepts
        SET listing  = listing || eu_aggregate_children_listing(tmp_node_id)
        WHERE id = tmp_node_id;
      END LOOP;
    END;
  $$;


--
-- Name: rebuild_ancestor_eu_listing_recursively_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_eu_listing_recursively_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      children_node_ids INTEGER[];
      tmp_node_id INT;
    BEGIN
      SELECT ARRAY_AGG_NOTNULL(id) INTO children_node_ids
      FROM taxon_concepts
      WHERE parent_id = node_id;
      -- if there are children, rebuild their aggregated listing first
      FOREACH tmp_node_id IN ARRAY children_node_ids
      LOOP
        PERFORM rebuild_ancestor_eu_listing_recursively_for_node(tmp_node_id);
      END LOOP;

      -- update this node's aggregated listing
      IF ARRAY_UPPER(children_node_ids, 1) IS NULL THEN
        UPDATE taxon_concepts
        SET listing = listing || eu_leaf_listing(node_id)
        WHERE id = node_id;
      ELSE
        UPDATE taxon_concepts
        SET listing = listing || eu_aggregate_children_listing(node_id)
        WHERE id = node_id;
      END IF;
    END;
  $$;


--
-- Name: rebuild_ancestor_valid_tc_appdx_year_designation_mview(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_valid_tc_appdx_year_designation_mview(designation_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      node_id INT;
    BEGIN
  FOR node_id IN SELECT taxon_concepts.id FROM taxon_concepts
    JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
    AND taxonomies.name = 'CITES_EU' AND name_status IN ('A', 'N', 'H')
    WHERE parent_id IS NULL
  LOOP
    PERFORM rebuild_ancestor_valid_tc_appdx_year_designation_mview_for_node(designation_name, node_id);
  END LOOP;
  RETURN;
    END;
  $$;


--
-- Name: rebuild_ancestor_valid_tc_appdx_year_designation_mview_for_node(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_valid_tc_appdx_year_designation_mview_for_node(designation_name character varying, node_id integer) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $$
    DECLARE
      children_node_ids INTEGER[];
      tmp_node_id INT;
      mview_name VARCHAR;
      appendix VARCHAR;
      sql TEXT;
    BEGIN
      SELECT ARRAY_AGG_NOTNULL(id) INTO children_node_ids
      FROM taxon_concepts
      WHERE parent_id = node_id;
      -- if there are children, rebuild their aggregated listing first
      FOREACH tmp_node_id IN ARRAY children_node_ids
      LOOP
        PERFORM rebuild_ancestor_valid_tc_appdx_year_designation_mview_for_node(designation_name, tmp_node_id);
      END LOOP;

      IF ARRAY_UPPER(children_node_ids, 1) IS NOT NULL THEN
        IF designation_name = 'EU' THEN
          appendix := 'annex';
        ELSE
          appendix := 'appendix';
        END IF;

        mview_name := 'valid_taxon_concept_' || appendix || '_year_mview';
        -- update this node's aggregated listing
        sql := '
          WITH children_intervals AS (
            SELECT taxon_concepts.id, taxon_concepts.parent_id, taxon_concepts.full_name
            FROM taxon_concepts
            JOIN ' || mview_name || ' t
            ON t.taxon_concept_id = taxon_concepts.id
            WHERE taxon_concepts.name_status IN (''A'', ''N'', ''H'')
            AND taxon_concepts.parent_id = ' || node_id || '
            GROUP BY taxon_concepts.id, taxon_concepts.parent_id, taxon_concepts.full_name
          )
          INSERT INTO ' || mview_name || '
          (taxon_concept_id, ' || appendix || ', effective_from, effective_to)
          SELECT COALESCE(parent_id, id) AS taxon_concept_id,
          ' || appendix || ', effective_from, effective_to
          FROM children_intervals
          JOIN ' || mview_name || ' t
          ON children_intervals.id = t.taxon_concept_id OR children_intervals.parent_id = t.taxon_concept_id
          GROUP BY COALESCE(parent_id, id), ' || appendix || ', effective_from, effective_to';
        EXECUTE sql;
      END IF;
    END;
  $$;


--
-- Name: rebuild_cites_accepted_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_accepted_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    PERFORM rebuild_cites_accepted_flags_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_cites_accepted_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_accepted_flags() IS 'Procedure to rebuild the cites_accepted flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - CITES accepted name, "f" - not accepted, but shows in Checklist, null - not accepted, doesn''t show';


--
-- Name: rebuild_cites_accepted_flags_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_accepted_flags_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      cites_eu_id int;
      ancestor_node_id int;
    BEGIN
    SELECT id INTO cites_eu_id FROM taxonomies WHERE name = 'CITES_EU';
    -- set the cites_accepted flag to null for all taxa (so we start clear)
    UPDATE taxon_concepts SET data =
      CASE
        WHEN data IS NULL THEN ''::HSTORE
        ELSE data
      END || hstore('cites_accepted', NULL)
    WHERE taxonomy_id = cites_eu_id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    -- set the cites_accepted flag to true for all explicitly referenced taxa
    UPDATE taxon_concepts
    SET data = data || hstore('cites_accepted', 't')
    FROM (
      SELECT taxon_concepts.id
      FROM taxon_concepts
      INNER JOIN taxon_concept_references
        ON taxon_concept_references.taxon_concept_id = taxon_concepts.id
      INNER JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
        AND taxonomies.name = 'CITES_EU'
      WHERE
        taxon_concept_references.is_standard = TRUE
        AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END
    ) AS q
    WHERE taxon_concepts.id = q.id;

    -- set the cites_accepted flag to false for all synonyms
    UPDATE taxon_concepts
    SET data = data || hstore('cites_accepted', 'f')
    FROM (
      SELECT taxon_relationships.other_taxon_concept_id AS id
      FROM taxon_relationships
      INNER JOIN taxon_relationship_types
        ON taxon_relationship_types.id =
          taxon_relationships.taxon_relationship_type_id
      INNER JOIN taxon_concepts
        ON taxon_concepts.id = taxon_relationships.other_taxon_concept_id
      INNER JOIN taxonomies
        ON taxonomies.id = taxon_concepts.taxonomy_id
        AND taxonomies.name = 'CITES_EU'
      WHERE
        taxon_relationship_types.name = 'HAS_SYNONYM'
        AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END
    ) AS q
    WHERE taxon_concepts.id = q.id;

    -- set the usr_no_std_ref for exclusions
    UPDATE taxon_concepts
    SET data = data || hstore('usr_no_std_ref', 't')
    FROM (
      WITH RECURSIVE cascading_refs AS (
        SELECT h.id, h.parent_id, taxon_concept_references.excluded_taxon_concepts_ids exclusions, false AS i_am_excluded
        FROM taxon_concept_references
        INNER JOIN taxon_concepts h
          ON h.id = taxon_concept_references.taxon_concept_id
        WHERE taxon_concept_references.is_cascaded AND
        CASE WHEN node_id IS NOT NULL THEN h.id = node_id ELSE TRUE END

        UNION

        SELECT hi.id, hi.parent_id, exclusions, exclusions @> ARRAY[hi.id]
        FROM cascading_refs
        JOIN taxon_concepts hi
        ON hi.parent_id = cascading_refs.id
      )
      SELECT id, BOOL_AND(i_am_excluded) AS i_am_excluded --excluded from all parent refs
      FROM cascading_refs
      GROUP BY id
    ) AS q
    WHERE taxon_concepts.id = q.id AND i_am_excluded;

    IF node_id IS NOT NULL THEN
      WITH RECURSIVE ancestors AS (
        SELECT h.id, h.parent_id, h_ref.is_standard AS is_std_ref,
          h_ref.is_cascaded AS cascade
        FROM taxon_concepts h
        LEFT JOIN taxon_concept_references h_ref
          ON h_ref.taxon_concept_id = h.id
        WHERE h.id = node_id

        UNION

        SELECT hi.id, hi.parent_id, hi_ref.is_standard,
          hi_ref.is_cascaded
        FROM taxon_concepts hi JOIN ancestors ON hi.id = ancestors.parent_id
        LEFT JOIN taxon_concept_references hi_ref
          ON hi_ref.taxon_concept_id = hi.id
      )
      SELECT id INTO ancestor_node_id
      FROM ancestors
      WHERE is_std_ref AND cascade
      LIMIT 1;
    END IF;

    -- set the cites_accepted flag to true for all implicitly referenced taxa
    WITH RECURSIVE q AS
    (
      SELECT  h.id, h.parent_id, h.data,
        CASE
          WHEN (h.data->'usr_no_std_ref')::BOOLEAN = 't' THEN 'f'
          ELSE (h.data->'cites_accepted')::BOOLEAN
        END AS inherited_cites_accepted
      FROM taxon_concept_references
      INNER JOIN taxon_concepts h
        ON h.id = taxon_concept_references.taxon_concept_id
      WHERE taxon_concept_references.is_cascaded AND
      CASE WHEN ancestor_node_id IS NOT NULL THEN h.id = ancestor_node_id ELSE TRUE END

      UNION

      SELECT  hi.id, hi.parent_id, hi.data,
      CASE
        WHEN (hi.data->'cites_accepted')::BOOLEAN = 't' THEN 't'
        WHEN (hi.data->'usr_no_std_ref')::BOOLEAN = 't' THEN 'f'
        ELSE inherited_cites_accepted
      END
      FROM    q
      JOIN    taxon_concepts hi
      ON      hi.parent_id = q.id
    )
    UPDATE taxon_concepts
    SET data = taxon_concepts.data || hstore('cites_accepted', (q.inherited_cites_accepted)::VARCHAR)
    FROM q
    WHERE taxon_concepts.id = q.id;

    -- set the cites_accepted flag to false where it is not set
    UPDATE taxon_concepts
    SET data = taxon_concepts.data || hstore('cites_accepted', 'f')
    WHERE (taxon_concepts.data->'cites_accepted')::BOOLEAN IS NULL AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    END;
  $$;


--
-- Name: rebuild_cites_annotation_symbols(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_annotation_symbols() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    PERFORM rebuild_cites_annotation_symbols_for_node(NULL);
    PERFORM rebuild_cites_hash_annotation_symbols_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_cites_annotation_symbols(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_annotation_symbols() IS 'Procedure to rebuild generic and specific annotation symbols to be used in the CITES index pdf.';


--
-- Name: rebuild_cites_annotation_symbols_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_annotation_symbols_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN

    WITH listing_changes_with_annotations AS (
      SELECT taxon_concept_id,
        listing_changes.id AS listing_change_id,
        annotations.id AS annotation_id
      FROM listing_changes
      INNER JOIN annotations
        ON listing_changes.annotation_id = annotations.id
      INNER JOIN change_types
        ON listing_changes.change_type_id = change_types.id
      INNER JOIN designations
        ON change_types.designation_id = designations.id AND designations.name = 'CITES'
      WHERE is_current = TRUE AND display_in_index = TRUE
      GROUP BY taxon_concept_id, listing_changes.id, annotations.id
    ), ordered_annotations AS (
      SELECT ROW_NUMBER() OVER(ORDER BY taxonomic_position) AS calculated_symbol,
        -- ignore split listings
        MAX(listing_change_id) AS listing_change_id, MAX(annotation_id) AS annotation_id
      FROM listing_changes_with_annotations listing_changes
      INNER JOIN taxon_concepts
        ON listing_changes.taxon_concept_id = taxon_concepts.id
      GROUP BY taxon_concept_id, taxonomic_position
    ), updated_annotations AS (
      UPDATE annotations
      SET symbol = ordered_annotations.calculated_symbol, parent_symbol = NULL
      FROM ordered_annotations
      WHERE ordered_annotations.annotation_id = annotations.id
    )
    UPDATE cites_listing_changes_mview
    SET ann_symbol = ordered_annotations.calculated_symbol
    FROM ordered_annotations
    WHERE ordered_annotations.listing_change_id = cites_listing_changes_mview.id;

    --clear all annotation symbols (non-hash ones)
    UPDATE taxon_concepts
    SET listing = listing - ARRAY['ann_symbol'];

    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) || hstore('ann_symbol', taxon_concept_annotations.symbol)
    FROM
    (
      SELECT taxon_concept_id, MAX(ann_symbol) AS symbol
      FROM cites_listing_changes_mview
      WHERE is_current = TRUE AND display_in_index = TRUE
      GROUP BY taxon_concept_id
    ) taxon_concept_annotations
    WHERE
      taxon_concept_annotations.taxon_concept_id = taxon_concepts.id;
    END;
  $$;


--
-- Name: rebuild_cites_eu_taxon_concepts_and_ancestors_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_eu_taxon_concepts_and_ancestors_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
  BEGIN
    SELECT * INTO taxonomy FROM taxonomies WHERE name = 'CITES_EU';
    IF FOUND THEN
      PERFORM rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy);
    END IF;
  END;
  $$;


--
-- Name: rebuild_cites_hash_annotation_symbols_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_hash_annotation_symbols_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN

    UPDATE taxon_concepts
    SET listing = listing - ARRAY['hash_ann_symbol', 'hash_ann_parent_symbol']
    WHERE CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
      hstore('hash_ann_symbol', taxon_concept_hash_annotations.symbol) ||
      hstore('hash_ann_parent_symbol', taxon_concept_hash_annotations.parent_symbol)
    FROM
    (
      SELECT taxon_concept_id, MAX(hash_ann_symbol) AS symbol, MAX(hash_ann_parent_symbol) AS parent_symbol
      FROM cites_listing_changes_mview
      WHERE is_current = TRUE
      GROUP BY taxon_concept_id
    ) taxon_concept_hash_annotations
    WHERE
      taxon_concept_hash_annotations.taxon_concept_id = taxon_concepts.id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    END;
  $$;


--
-- Name: rebuild_cites_listed_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_listed_status() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_cites_listed_status_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_cites_listed_status(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_listed_status() IS '
  Procedure to rebuild the cites status flags in taxon_concepts.listing.
  1. cites_status
    "LISTED" - explicit/implicit cites listing,
    "DELETED" - taxa previously listed and then deleted
    "EXCLUDED" - taxonomic exceptions
  2. cites_status_original
    TRUE - cites_status is explicit (original)
    FALSE - cites_status is implicit (inherited)
  3. cites_show
    TRUE - taxon should show up in the checklist
    FALSE
';


--
-- Name: rebuild_cites_listed_status_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_listed_status_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CITES';
    IF NOT FOUND THEN
      RETURN;
    END IF;
    PERFORM rebuild_listing_status_for_designation_and_node(designation, node_id);
    PERFORM set_cites_historically_listed_flag_for_node(node_id);
    END;
  $$;


--
-- Name: rebuild_cites_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    PERFORM rebuild_cites_annotation_symbols_for_node(NULL);
    PERFORM rebuild_cites_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_cites_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_listing() IS 'Procedure to rebuild CITES listing in taxon_concepts.';


--
-- Name: rebuild_cites_listing_changes_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_listing_changes_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
    designation designations%ROWTYPE;
    tmp_listing_changes_mview TEXT;
    tmp_current_listing_changes_mview TEXT;
  BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CITES';
    IF FOUND THEN
      SELECT * INTO taxonomy FROM taxonomies WHERE id = designation.taxonomy_id;
      PERFORM rebuild_designation_all_listing_changes_mview(
        taxonomy, designation, NULL
      );
      PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation, NULL);
      SELECT listing_changes_mview_name('tmp', designation.name, NULL)
      INTO tmp_listing_changes_mview;
      SELECT listing_changes_mview_name('tmp_current', designation.name, NULL)
      INTO tmp_current_listing_changes_mview;
      EXECUTE 'DROP VIEW IF EXISTS ' || tmp_current_listing_changes_mview;
      EXECUTE 'CREATE VIEW ' || tmp_current_listing_changes_mview || ' AS
      SELECT * FROM ' || tmp_listing_changes_mview || '
      WHERE is_current';
    END IF;
  END;
  $$;


--
-- Name: rebuild_cites_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    PERFORM rebuild_cites_listed_status_for_node(node_id);
    PERFORM rebuild_cites_not_listed_status_for_node(node_id);
    PERFORM rebuild_cites_hash_annotation_symbols_for_node(node_id);
    PERFORM rebuild_explicit_cites_listing_for_node(node_id);
    PERFORM rebuild_ancestor_cites_listing_for_node(node_id);
    END;
  $$;


--
-- Name: rebuild_cites_not_listed_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_not_listed_status() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_cites_not_listed_status_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_cites_not_listed_status(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_not_listed_status() IS '
  Procedure to rebuild the cites_fully_covered AND cites_not_listed flags in taxon_concepts.listing.
  1. cites_fully_covered
    TRUE - all descendants are listed,
    FALSE - some descendants were excluded or deleted from listing
  2. cites_not_listed
    NC - either this taxon or some of its descendants were excluded or deleted from listing
';


--
-- Name: rebuild_cites_not_listed_status_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_not_listed_status_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CITES';
    PERFORM rebuild_not_listed_status_for_designation_and_node(designation, node_id);
    END;
  $$;


--
-- Name: rebuild_cites_species_listing_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_species_listing_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
  
  DROP TABLE IF EXISTS cites_species_listing_mview_tmp;

CREATE TABLE cites_species_listing_mview_tmp AS
SELECT
  taxon_concepts_mview.id AS id,
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.kingdom_id AS kingdom_id,
  taxon_concepts_mview.phylum_id AS phylum_id,
  taxon_concepts_mview.class_id AS class_id,
  taxon_concepts_mview.order_id AS order_id,
  taxon_concepts_mview.family_id AS family_id,
  taxon_concepts_mview.genus_id AS genus_id,
  taxon_concepts_mview.kingdom_name AS kingdom_name,
  taxon_concepts_mview.phylum_name AS phylum_name,
  taxon_concepts_mview.class_name AS class_name,
  taxon_concepts_mview.order_name AS order_name,
  taxon_concepts_mview.family_name AS family_name,
  taxon_concepts_mview.genus_name AS genus_name,
  taxon_concepts_mview.species_name AS species_name,
  taxon_concepts_mview.subspecies_name AS subspecies_name,
  taxon_concepts_mview.full_name AS full_name,
  taxon_concepts_mview.author_year AS author_year,
  taxon_concepts_mview.rank_name AS rank_name,
  taxon_concepts_mview.cites_listed, 
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0 
    OR taxon_concepts_mview.cites_listing_original = 'NC'
    THEN TRUE
    ELSE FALSE
  END AS cites_nc,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0 
    THEN 'NC'
    ELSE taxon_concepts_mview.cites_listing_original
  END AS cites_listing_original,
  ARRAY_TO_STRING(
    ARRAY_AGG(DISTINCT listing_changes_mview.party_iso_code),
    ','
  ) AS original_taxon_concept_party_iso_code,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      DISTINCT full_name_with_spp(
        COALESCE(inclusion_taxon_concepts_mview.rank_name, original_taxon_concepts_mview.rank_name),
        COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name)
      )
    ),
    ','
  ) AS original_taxon_concept_full_name_with_spp,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || listing_changes_mview.species_listing_name || '** '
      || CASE 
        WHEN LENGTH(listing_changes_mview.auto_note_en) > 0 THEN '[' || listing_changes_mview.auto_note_en || '] ' 
        ELSE '' 
      END 
      || CASE 
        WHEN LENGTH(listing_changes_mview.inherited_full_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_en) 
        WHEN LENGTH(listing_changes_mview.inherited_short_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_en) 
        WHEN LENGTH(listing_changes_mview.full_note_en) > 0 THEN strip_tags(listing_changes_mview.full_note_en) 
        ELSE strip_tags(listing_changes_mview.short_note_en) 
      END
      ORDER BY listing_changes_mview.species_listing_name
    ),
    E'\n'
  ) AS original_taxon_concept_full_note_en,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || species_listing_name || '** ' || listing_changes_mview.hash_ann_symbol || ' ' 
      || strip_tags(listing_changes_mview.hash_full_note_en)
      ORDER BY species_listing_name
    ),
    E'\n'
  ) AS original_taxon_concept_hash_full_note_en,
  taxon_concepts_mview.countries_ids_ary,
  ARRAY_TO_STRING(taxon_concepts_mview.all_distribution_ary_en, ',') AS all_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.all_distribution_iso_codes_ary, ',') AS all_distribution_iso_codes,
  ARRAY_TO_STRING(taxon_concepts_mview.native_distribution_ary_en, ',') AS native_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.introduced_distribution_ary_en, ',') AS introduced_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.introduced_uncertain_distribution_ary_en, ',') AS introduced_uncertain_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.reintroduced_distribution_ary_en, ',') AS reintroduced_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.extinct_distribution_ary_en, ',') AS extinct_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.extinct_uncertain_distribution_ary_en, ',') AS extinct_uncertain_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.uncertain_distribution_ary_en, ',') AS uncertain_distribution
FROM "taxon_concepts_mview"
JOIN cites_listing_changes_mview listing_changes_mview 
  ON listing_changes_mview.taxon_concept_id = taxon_concepts_mview.id
  AND is_current
  AND change_type_name = 'ADDITION'
JOIN taxon_concepts_mview original_taxon_concepts_mview
  ON listing_changes_mview.original_taxon_concept_id = original_taxon_concepts_mview.id
LEFT JOIN taxon_concepts_mview inclusion_taxon_concepts_mview
  ON listing_changes_mview.inclusion_taxon_concept_id = inclusion_taxon_concepts_mview.id 
WHERE "taxon_concepts_mview"."name_status" = 'A'
  AND "taxon_concepts_mview".taxonomy_is_cites_eu = TRUE
  AND "taxon_concepts_mview"."cites_show" = 't' 
  AND "taxon_concepts_mview"."rank_name" IN ('SPECIES', 'SUBSPECIES', 'VARIETY')
  AND (taxon_concepts_mview.cites_listing_original != 'NC') 
GROUP BY
  taxon_concepts_mview.id,
  taxon_concepts_mview.kingdom_id,
  taxon_concepts_mview.phylum_id,
  taxon_concepts_mview.class_id,
  taxon_concepts_mview.order_id,
  taxon_concepts_mview.family_id,
  taxon_concepts_mview.genus_id,
  taxon_concepts_mview.kingdom_name,
  taxon_concepts_mview.phylum_name,
  taxon_concepts_mview.class_name,
  taxon_concepts_mview.order_name,
  taxon_concepts_mview.family_name,
  taxon_concepts_mview.genus_name,
  taxon_concepts_mview.species_name,
  taxon_concepts_mview.subspecies_name,
  taxon_concepts_mview.full_name,
  taxon_concepts_mview.author_year,
  taxon_concepts_mview.rank_name,
  taxon_concepts_mview.cites_listed,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0 
    OR taxon_concepts_mview.cites_listing_original = 'NC'
    THEN TRUE
    ELSE FALSE
  END,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0 
    THEN 'NC' ELSE taxon_concepts_mview.cites_listing_original
  END,
  COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name),
  COALESCE(inclusion_taxon_concepts_mview.spp, original_taxon_concepts_mview.spp),
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.countries_ids_ary,
  taxon_concepts_mview.all_distribution_ary_en,
  taxon_concepts_mview.all_distribution_iso_codes_ary,
  taxon_concepts_mview.native_distribution_ary_en,
  taxon_concepts_mview.introduced_distribution_ary_en,
  taxon_concepts_mview.introduced_uncertain_distribution_ary_en,
  taxon_concepts_mview.reintroduced_distribution_ary_en,
  taxon_concepts_mview.extinct_distribution_ary_en,
  taxon_concepts_mview.extinct_uncertain_distribution_ary_en,
  taxon_concepts_mview.uncertain_distribution_ary_en;

  CREATE INDEX ON cites_species_listing_mview_tmp USING GIN (countries_ids_ary); -- search by geo entity

  DROP TABLE IF EXISTS cites_species_listing_mview;
  ALTER TABLE cites_species_listing_mview_tmp RENAME TO cites_species_listing_mview;

END;
$$;


--
-- Name: rebuild_cms_listed_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cms_listed_status() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_cms_listed_status_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_cms_listed_status(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cms_listed_status() IS '
  Procedure to rebuild the CMS status flags in taxon_concepts.listing.
  1. cms_status
    "LISTED" - explicit/implicit cites listing,
    "DELETED" - taxa previously listed and then deleted
    "EXCLUDED" - taxonomic exceptions
  2. cms_status_original
    TRUE - cites_status is explicit (original)
    FALSE - cites_status is implicit (inherited)
';


--
-- Name: rebuild_cms_listed_status_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cms_listed_status_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CMS';
    IF NOT FOUND THEN
      RETURN;
    END IF;

    PERFORM rebuild_listing_status_for_designation_and_node(designation, node_id);
    PERFORM set_cms_historically_listed_flag_for_node(node_id);
    END;
  $$;


--
-- Name: rebuild_cms_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cms_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    PERFORM rebuild_cms_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_cms_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cms_listing() IS 'Procedure to rebuild CMS listing in taxon_concepts.';


--
-- Name: rebuild_cms_listing_changes_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cms_listing_changes_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
    designation designations%ROWTYPE;
    tmp_listing_changes_mview TEXT;
    tmp_current_listing_changes_mview TEXT;
  BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CMS';
    IF FOUND THEN
      SELECT * INTO taxonomy FROM taxonomies WHERE id = designation.taxonomy_id;
      PERFORM rebuild_designation_all_listing_changes_mview(
        taxonomy, designation, NULL
      );
      PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation, NULL);
      SELECT listing_changes_mview_name('tmp', designation.name, NULL)
      INTO tmp_listing_changes_mview;
      SELECT listing_changes_mview_name('tmp_current', designation.name, NULL)
      INTO tmp_current_listing_changes_mview;
      EXECUTE 'DROP VIEW IF EXISTS ' || tmp_current_listing_changes_mview;
      EXECUTE 'CREATE VIEW ' || tmp_current_listing_changes_mview || ' AS
      SELECT * FROM ' || tmp_listing_changes_mview || '
      WHERE is_current';
    END IF;
  END;
  $$;


--
-- Name: rebuild_cms_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cms_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    PERFORM rebuild_cms_listed_status_for_node(node_id);
    PERFORM rebuild_cms_not_listed_status_for_node(node_id);
    PERFORM rebuild_explicit_cms_listing_for_node(node_id);
    PERFORM rebuild_ancestor_cms_listing_for_node(node_id);
    END;
  $$;


--
-- Name: rebuild_cms_not_listed_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cms_not_listed_status() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_cms_not_listed_status_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_cms_not_listed_status(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cms_not_listed_status() IS '
  Procedure to rebuild the cms_fully_covered AND cms_not_listed flags in taxon_concepts.listing.
  1. cms_fully_covered
    TRUE - all descendants are listed,
    FALSE - some descendants were excluded or deleted from listing
  2. cms_not_listed
    NC - either this taxon or some of its descendants were excluded or deleted from listing
';


--
-- Name: rebuild_cms_not_listed_status_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cms_not_listed_status_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CMS';
    IF NOT FOUND THEN
      RETURN;
    END IF;
    PERFORM rebuild_not_listed_status_for_designation_and_node(designation, node_id);
    END;
  $$;


--
-- Name: rebuild_cms_species_listing_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cms_species_listing_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN

  DROP TABLE IF EXISTS cms_species_listing_mview_tmp;

CREATE TABLE cms_species_listing_mview_tmp AS
SELECT
  taxon_concepts_mview.id AS id,
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.kingdom_id AS kingdom_id,
  taxon_concepts_mview.phylum_id AS phylum_id,
  taxon_concepts_mview.class_id AS class_id,
  taxon_concepts_mview.order_id AS order_id,
  taxon_concepts_mview.family_id AS family_id,
  taxon_concepts_mview.genus_id AS genus_id,
  taxon_concepts_mview.phylum_name AS phylum_name,
  taxon_concepts_mview.class_name AS class_name,
  taxon_concepts_mview.order_name AS order_name,
  taxon_concepts_mview.family_name AS family_name,
  taxon_concepts_mview.genus_name AS genus_name,
  taxon_concepts_mview.full_name AS full_name,
  taxon_concepts_mview.author_year AS author_year,
  taxon_concepts_mview.rank_name AS rank_name,
  'CMS' AS agreement,
  taxon_concepts_mview.cms_listed,
  taxon_concepts_mview.cms_listing_original AS cms_listing_original,
  ARRAY_TO_STRING(
    ARRAY_AGG(DISTINCT full_name_with_spp(original_taxon_concepts_mview.rank_name, original_taxon_concepts_mview.full_name)),
    ','
  ) AS original_taxon_concept_full_name_with_spp,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || listing_changes_mview.species_listing_name || '** '
      || to_char(listing_changes_mview.effective_at, 'DD/MM/YYYY')
      ORDER BY listing_changes_mview.species_listing_name
    ),
    E'\n'
  ) AS original_taxon_concept_effective_at,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || listing_changes_mview.species_listing_name || '** '
      || CASE 
      WHEN LENGTH(listing_changes_mview.auto_note_en) > 0 THEN '[' || listing_changes_mview.auto_note_en || '] ' 
      ELSE '' 
      END 
      || CASE 
      WHEN LENGTH(listing_changes_mview.full_note_en) > 0 THEN strip_tags(listing_changes_mview.full_note_en) 
      ELSE strip_tags(listing_changes_mview.short_note_en) 
      END
      ORDER BY listing_changes_mview.species_listing_name
    ),
    E'\n'
  ) AS original_taxon_concept_full_note_en,
  taxon_concepts_mview.countries_ids_ary,
  ARRAY_TO_STRING(taxon_concepts_mview.all_distribution_ary_en, ',') AS all_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.all_distribution_iso_codes_ary, ',') AS all_distribution_iso_codes,
  ARRAY_TO_STRING(taxon_concepts_mview.native_distribution_ary_en, ',') AS native_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.introduced_distribution_ary_en, ',') AS introduced_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.introduced_uncertain_distribution_ary_en, ',') AS introduced_uncertain_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.reintroduced_distribution_ary_en, ',') AS reintroduced_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.extinct_distribution_ary_en, ',') AS extinct_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.extinct_uncertain_distribution_ary_en, ',') AS extinct_uncertain_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.uncertain_distribution_ary_en, ',') AS uncertain_distribution
FROM "taxon_concepts_mview"
JOIN cms_listing_changes_mview listing_changes_mview
   ON listing_changes_mview.taxon_concept_id = taxon_concepts_mview.id
   AND is_current
   AND change_type_name = 'ADDITION'
JOIN taxon_concepts_mview original_taxon_concepts_mview
   ON listing_changes_mview.original_taxon_concept_id = original_taxon_concepts_mview.id
LEFT JOIN taxon_concepts_mview inclusion_taxon_concepts_mview
   ON listing_changes_mview.inclusion_taxon_concept_id = inclusion_taxon_concepts_mview.id 
WHERE "taxon_concepts_mview"."name_status" = 'A'
   AND "taxon_concepts_mview"."taxonomy_is_cites_eu" = FALSE 
   AND "taxon_concepts_mview"."cms_show" = 't' 
   AND "taxon_concepts_mview"."rank_name" IN ('SPECIES', 'SUBSPECIES', 'VARIETY') 
   AND (taxon_concepts_mview.cms_listing_original != 'NC') 
GROUP BY 
  taxon_concepts_mview.id,
  taxon_concepts_mview.kingdom_id,
  taxon_concepts_mview.phylum_id,
  taxon_concepts_mview.class_id,
  taxon_concepts_mview.order_id,
  taxon_concepts_mview.family_id,
  taxon_concepts_mview.genus_id,
  taxon_concepts_mview.phylum_name,
  taxon_concepts_mview.class_name,
  taxon_concepts_mview.order_name,
  taxon_concepts_mview.family_name,
  taxon_concepts_mview.genus_name,
  taxon_concepts_mview.full_name,
  taxon_concepts_mview.author_year,
  taxon_concepts_mview.rank_name,
  taxon_concepts_mview.cms_listed,
  taxon_concepts_mview.cms_listing_original,
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.countries_ids_ary,
  taxon_concepts_mview.all_distribution_ary_en,
  taxon_concepts_mview.all_distribution_iso_codes_ary,
  taxon_concepts_mview.native_distribution_ary_en,
  taxon_concepts_mview.introduced_distribution_ary_en,
  taxon_concepts_mview.introduced_uncertain_distribution_ary_en,
  taxon_concepts_mview.reintroduced_distribution_ary_en,
  taxon_concepts_mview.extinct_distribution_ary_en,
  taxon_concepts_mview.extinct_uncertain_distribution_ary_en,
  taxon_concepts_mview.uncertain_distribution_ary_en

UNION

SELECT
  taxon_concepts_mview.id AS id,
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.kingdom_id AS kingdom_id,
  taxon_concepts_mview.phylum_id AS phylum_id,
  taxon_concepts_mview.class_id AS class_id,
  taxon_concepts_mview.order_id AS order_id,
  taxon_concepts_mview.family_id AS family_id,
  taxon_concepts_mview.genus_id,
  taxon_concepts_mview.phylum_name AS phylum_name,
  taxon_concepts_mview.class_name AS class_name,
  taxon_concepts_mview.order_name AS order_name,
  taxon_concepts_mview.family_name AS family_name,
  taxon_concepts_mview.genus_name AS genus_name,
  taxon_concepts_mview.full_name AS full_name,
  taxon_concepts_mview.author_year AS author_year,
  taxon_concepts_mview.rank_name AS rank_name,
  instruments.name AS agreement,
  NULL,
  '',
  '',
  to_char(taxon_instruments.effective_from, 'DD/MM/YYYY') AS effective_at,
  '',
  '{}'::INT[],
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
 FROM taxon_instruments
 JOIN taxon_concepts_mview
   ON taxon_instruments.taxon_concept_id = taxon_concepts_mview.id
 JOIN instruments
   ON taxon_instruments.instrument_id = instruments.id;

  CREATE INDEX ON cms_species_listing_mview_tmp USING GIN (countries_ids_ary); -- search by geo entity

  DROP TABLE IF EXISTS cms_species_listing_mview;
  ALTER TABLE cms_species_listing_mview_tmp RENAME TO cms_species_listing_mview;

END;
$$;


--
-- Name: rebuild_cms_taxon_concepts_and_ancestors_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cms_taxon_concepts_and_ancestors_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
  BEGIN
    SELECT * INTO taxonomy FROM taxonomies WHERE name = 'CMS';
    IF FOUND THEN
      PERFORM rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy);
    END IF;
  END;
  $$;


--
-- Name: rebuild_descendant_cites_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_descendant_cites_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_descendant_cites_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_descendant_cites_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_descendant_cites_listing() IS 'Procedure to rebuild CITES descendant listings in taxon_concepts.';


--
-- Name: rebuild_descendant_cites_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_descendant_cites_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CITES';
    PERFORM rebuild_descendant_listing_for_designation_and_node(designation, node_id);
    END;
  $$;


--
-- Name: rebuild_descendant_cms_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_descendant_cms_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_descendant_cms_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_descendant_cms_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_descendant_cms_listing() IS 'Procedure to rebuild CMS descendant listings in taxon_concepts.';


--
-- Name: rebuild_descendant_cms_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_descendant_cms_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CMS';
    PERFORM rebuild_descendant_listing_for_designation_and_node(designation, node_id);
    END;
  $$;


--
-- Name: rebuild_descendant_eu_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_descendant_eu_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_descendant_eu_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_descendant_eu_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_descendant_eu_listing() IS 'Procedure to rebuild EU descendant listings in taxon_concepts.';


--
-- Name: rebuild_descendant_eu_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_descendant_eu_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'EU';
    PERFORM rebuild_descendant_listing_for_designation_and_node(designation, node_id);
    END;
  $$;


--
-- Name: designations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE designations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    taxonomy_id integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rebuild_descendant_listing_for_designation_and_node(designations, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_descendant_listing_for_designation_and_node(designation designations, node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      ancestor_node_id integer;
      fully_covered_flag varchar;
      not_listed_flag varchar;
      status_original_flag varchar;
      status_flag varchar;
      listing_original_flag varchar;
      listing_flag varchar;
      level_of_listing_flag varchar;
    BEGIN

    fully_covered_flag := LOWER(designation.name) || '_fully_covered';
    not_listed_flag := LOWER(designation.name) || '_not_listed';
    status_original_flag := LOWER(designation.name) || '_status_original';
    status_flag := LOWER(designation.name) || '_status';
    listing_original_flag := LOWER(designation.name) || '_listing_original';
    listing_flag := LOWER(designation.name) || '_listing';
    level_of_listing_flag := LOWER(designation.name) || '_level_of_listing';

    IF node_id IS NOT NULL THEN
      WITH RECURSIVE ancestors AS (
        SELECT h.id, h.parent_id, h.listing
        FROM taxon_concepts h WHERE id = node_id

        UNION

        SELECT hi.id, hi.parent_id, hi.listing
        FROM taxon_concepts hi JOIN ancestors ON hi.id = ancestors.parent_id
      )
      SELECT id INTO ancestor_node_id
      FROM ancestors
      WHERE (listing->status_original_flag)::BOOLEAN = TRUE
      LIMIT 1;

      IF FOUND THEN
        node_id := ancestor_node_id;
      END IF;
    END IF;

    WITH RECURSIVE q AS (
      SELECT h.id, parent_id,
      hstore(listing_flag,
        CASE
          WHEN listing->status_flag = 'LISTED'
          THEN listing->listing_original_flag
          WHEN listing->not_listed_flag = 'NC'
          THEN listing->not_listed_flag
          ELSE NULL
        END
      )  ||
      slice(h.listing, ARRAY[listing_original_flag, fully_covered_flag,'hash_ann_symbol', 'ann_symbol']) ||
      CASE
        WHEN designation.name = 'CITES' THEN slice(h.listing, ARRAY['cites_I', 'cites_II', 'cites_III'])
        WHEN designation.name = 'EU' THEN slice(h.listing, ARRAY['eu_A', 'eu_B', 'eu_C', 'eu_D'])
        WHEN designation.name = 'CMS' THEN slice(h.listing, ARRAY['cms_I', 'cms_II'])
        ELSE ''::HSTORE
      END
      AS inherited_listing
      FROM taxon_concepts h
      JOIN taxonomies ON h.taxonomy_id = taxonomies.id
      AND taxonomies.name = CASE WHEN designation.name = 'CMS' THEN 'CMS' ELSE 'CITES_EU' END
      WHERE CASE WHEN node_id IS NOT NULL THEN h.id = node_id ELSE h.parent_id IS NULL END

      UNION

      SELECT hi.id, hi.parent_id,
      CASE
      WHEN
        (hi.listing->status_original_flag)::BOOLEAN
      THEN
        hstore(listing_flag, hi.listing->listing_original_flag) ||
        slice(hi.listing, ARRAY[listing_original_flag, fully_covered_flag,'hash_ann_symbol', 'ann_symbol']) ||
        CASE
          WHEN designation.name = 'CITES' THEN slice(hi.listing, ARRAY['cites_I', 'cites_II', 'cites_III'])
          WHEN designation.name = 'EU' THEN slice(hi.listing, ARRAY['eu_A', 'eu_B', 'eu_C', 'eu_D'])
          WHEN designation.name = 'CMS' 
          THEN HSTORE('cms_I', COALESCE(hi.listing->'cms_I', inherited_listing->'cms_I'))
          || HSTORE('cms_II', COALESCE(hi.listing->'cms_II', inherited_listing->'cms_II'))
          ELSE ''::HSTORE
        END
      ELSE
        inherited_listing
      END
      FROM q
      JOIN taxon_concepts hi
      ON hi.parent_id = q.id
    )
    UPDATE taxon_concepts
    SET
    listing = listing ||
    CASE
    WHEN listing->status_flag = 'EXCLUDED' OR listing->status_flag = 'DELETED'
    THEN q.inherited_listing - ARRAY[not_listed_flag]
    ELSE q.inherited_listing
    END
    FROM q
    WHERE taxon_concepts.id = q.id;
    END;
  $$;


--
-- Name: taxonomies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxonomies (
    id integer NOT NULL,
    name character varying(255) DEFAULT 'DEAFAULT TAXONOMY'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rebuild_designation_all_listing_changes_mview(taxonomies, designations, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_designation_all_listing_changes_mview(taxonomy taxonomies, designation designations, events_ids integer[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    all_lc_table_name TEXT;
    tmp_lc_table_name TEXT;
    tc_table_name TEXT;
    sql TEXT;
  BEGIN
    SELECT listing_changes_mview_name('all', designation.name, events_ids)
    INTO all_lc_table_name;
    SELECT listing_changes_mview_name('tmp', designation.name, events_ids)
    INTO tmp_lc_table_name;

    SELECT LOWER(taxonomy.name) || '_taxon_concepts_and_ancestors_mview' INTO tc_table_name;

    EXECUTE 'DROP TABLE IF EXISTS ' || tmp_lc_table_name || ' CASCADE';

    sql := 'CREATE TEMP TABLE ' || tmp_lc_table_name || ' AS
    -- affected_taxon_concept -- is a taxon concept that is affected by this listing change,
    -- even though it might not have an explicit connection to it
    -- (i.e. it''s an ancestor''s listing change)
    WITH listing_changes_with_exceptions AS (
      -- the purpose of this CTE is to aggregate excluded taxon concept ids
      SELECT
        listing_changes.id,
        change_types.designation_id,
        change_types.name AS change_type_name,
        listing_changes.taxon_concept_id,
        listing_changes.species_listing_id,
        listing_changes.change_type_id,
        listing_changes.inclusion_taxon_concept_id,
        listing_changes.event_id,
        listing_changes.effective_at::DATE,
        listing_changes.is_current,
        ARRAY_AGG_NOTNULL(taxonomic_exceptions.taxon_concept_id) AS excluded_taxon_concept_ids
      FROM listing_changes
      LEFT JOIN listing_changes taxonomic_exceptions
      ON listing_changes.id = taxonomic_exceptions.parent_id
      AND listing_changes.taxon_concept_id != taxonomic_exceptions.taxon_concept_id
      JOIN change_types ON change_types.id = listing_changes.change_type_id
      AND change_types.designation_id = ' || designation.id
      || CASE
      WHEN events_ids IS NOT NULL AND ARRAY_UPPER(events_ids, 1) IS NOT NULL
      THEN ' WHERE listing_changes.event_id = ANY (''{' || ARRAY_TO_STRING(events_ids, ', ') || '}''::INT[])'
      ELSE ''
      END ||
      '
      GROUP BY
        listing_changes.id,
        change_types.designation_id,
        change_types.name,
        listing_changes.taxon_concept_id,
        listing_changes.species_listing_id,
        listing_changes.change_type_id,
        listing_changes.inclusion_taxon_concept_id,
        listing_changes.event_id,
        listing_changes.effective_at::DATE,
        listing_changes.is_current
    )
    -- the purpose of this CTE is to aggregate listed and excluded populations
    SELECT lc.id,
      lc.designation_id,
      lc.change_type_name,
      lc.taxon_concept_id,
      lc.species_listing_id,
      lc.change_type_id,
      lc.inclusion_taxon_concept_id,
      lc.event_id,
      lc.effective_at,
      lc.is_current,
      lc.excluded_taxon_concept_ids,
      party_distribution.geo_entity_id AS party_id,
      ARRAY_AGG_NOTNULL(listing_distributions.geo_entity_id) AS listed_geo_entities_ids,
      ARRAY_AGG_NOTNULL(excluded_distributions.geo_entity_id) AS excluded_geo_entities_ids
    FROM listing_changes_with_exceptions lc
    LEFT JOIN listing_distributions
    ON lc.id = listing_distributions.listing_change_id AND NOT listing_distributions.is_party
    LEFT JOIN listing_distributions party_distribution
    ON lc.id = party_distribution.listing_change_id AND party_distribution.is_party
    LEFT JOIN listing_changes population_exceptions
    ON lc.id = population_exceptions.parent_id
    AND lc.taxon_concept_id = population_exceptions.taxon_concept_id
    LEFT JOIN listing_distributions excluded_distributions
    ON population_exceptions.id = excluded_distributions.listing_change_id AND NOT excluded_distributions.is_party
    GROUP BY lc.id,
      lc.designation_id,
      lc.change_type_name,
      lc.taxon_concept_id,
      lc.species_listing_id,
      lc.change_type_id,
      lc.inclusion_taxon_concept_id,
      lc.event_id,
      lc.effective_at,
      lc.is_current,
      party_distribution.geo_entity_id,
      lc.excluded_taxon_concept_ids';

    EXECUTE sql;

    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (taxon_concept_id)';
    -- for the current listing calculation
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (taxon_concept_id, is_current, change_type_name, inclusion_taxon_concept_id)';

    EXECUTE 'DROP TABLE IF EXISTS ' || all_lc_table_name || ' CASCADE';

    sql := 'CREATE TEMP TABLE ' || all_lc_table_name || ' AS
    SELECT
      lc.*, 
      tc.taxon_concept_id AS affected_taxon_concept_id, 
      tc.tree_distance, 
      -- the following ROW_NUMBER call will assign chronological order to listing changes
      -- in scope of the affected taxon concept and a particular designation
      ROW_NUMBER() OVER (
          PARTITION BY tc.taxon_concept_id, designation_id
          ORDER BY effective_at,
          CASE
            WHEN change_type_name = ''DELETION'' THEN 0
            WHEN change_type_name = ''RESERVATION_WITHDRAWAL'' THEN 1
            WHEN change_type_name = ''ADDITION'' THEN 2
            WHEN change_type_name = ''RESERVATION'' THEN 3
            WHEN change_type_name = ''EXCEPTION'' THEN 4
          END,
          tree_distance
      )::INT AS timeline_position
    FROM ' || tmp_lc_table_name || ' lc
    JOIN ' || tc_table_name || ' tc
    ON lc.taxon_concept_id = tc.ancestor_taxon_concept_id';

    EXECUTE sql;

    EXECUTE 'CREATE INDEX ON ' || all_lc_table_name || ' (designation_id, timeline_position, affected_taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || all_lc_table_name || ' (affected_taxon_concept_id, inclusion_taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || all_lc_table_name || ' (id, affected_taxon_concept_id)';

    -- make the tree distance reflect distance from inclusion (Rhinopittecus roxellana)
    sql := 'UPDATE ' || all_lc_table_name
    || ' SET tree_distance = tc.tree_distance
    FROM ' || all_lc_table_name || ' alc
    JOIN ' || tc_table_name || ' tc
    ON alc.inclusion_taxon_concept_id = tc.ancestor_taxon_concept_id
    AND alc.affected_taxon_concept_id = tc.taxon_concept_id
    WHERE alc.id = ' || all_lc_table_name || '.id
    AND alc.affected_taxon_concept_id = ' || all_lc_table_name || '.affected_taxon_concept_id';

    EXECUTE sql;

  END;
  $$;


--
-- Name: FUNCTION rebuild_designation_all_listing_changes_mview(taxonomy taxonomies, designation designations, events_ids integer[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_designation_all_listing_changes_mview(taxonomy taxonomies, designation designations, events_ids integer[]) IS 'Procedure to create a helper table with all listing changes 
  + their included / excluded populations 
  + tree distance between affected taxon concept and the taxon concept this listing change applies to.';


--
-- Name: rebuild_designation_listing_changes_mview(taxonomies, designations, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_designation_listing_changes_mview(taxonomy taxonomies, designation designations, events_ids integer[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    all_lc_table_name TEXT;
    tmp_lc_table_name TEXT;
    raw_lc_table_name TEXT;
    lc_table_name TEXT;
    sql TEXT;
    addition_id INT;
    deletion_id INT;
  BEGIN
    SELECT listing_changes_mview_name('all', designation.name, events_ids)
    INTO all_lc_table_name;
    SELECT listing_changes_mview_name('tmp', designation.name, events_ids)
    INTO raw_lc_table_name;
    SELECT listing_changes_mview_name('tmp_cascaded', designation.name, events_ids)
    INTO tmp_lc_table_name;
    SELECT listing_changes_mview_name(NULL, designation.name, events_ids)
    INTO lc_table_name;


    RAISE INFO 'Creating %', tmp_lc_table_name;
    EXECUTE 'DROP TABLE IF EXISTS ' || tmp_lc_table_name || ' CASCADE';

    sql := 'CREATE TABLE ' || tmp_lc_table_name || ' AS
    WITH applicable_listing_changes AS (
        SELECT affected_taxon_concept_id,'
        || designation.name || '_applicable_listing_changes_for_node(''' ||
          all_lc_table_name || ''', affected_taxon_concept_id
        ) AS listing_change_id
        FROM ' || all_lc_table_name
        || ' GROUP BY affected_taxon_concept_id
    )
    SELECT
    applicable_listing_changes.affected_taxon_concept_id AS taxon_concept_id,
    listing_changes.id AS id,
    listing_changes.taxon_concept_id AS original_taxon_concept_id,
    listing_changes.effective_at,
    listing_changes.species_listing_id,
    species_listings.abbreviation AS species_listing_name,
    listing_changes.change_type_id,
    change_types.name AS change_type_name,
    change_types.designation_id AS designation_id,
    designations.name AS designation_name,
    listing_changes.parent_id,
    tmp_lc.party_id,
    geo_entities.iso_code2 AS party_iso_code,
    geo_entities.name_en AS party_full_name_en,
    geo_entities.name_es AS party_full_name_es,
    geo_entities.name_fr AS party_full_name_fr,
    annotations.symbol AS ann_symbol,
    annotations.full_note_en,
    annotations.full_note_es,
    annotations.full_note_fr,
    annotations.short_note_en,
    annotations.short_note_es,
    annotations.short_note_fr,
    annotations.display_in_index,
    annotations.display_in_footnote,
    hash_annotations.symbol AS hash_ann_symbol,
    hash_annotations.parent_symbol AS hash_ann_parent_symbol,
    hash_annotations.full_note_en AS hash_full_note_en,
    hash_annotations.full_note_es AS hash_full_note_es,
    hash_annotations.full_note_fr AS hash_full_note_fr,
    listing_changes.inclusion_taxon_concept_id,
    NULL::TEXT AS inherited_short_note_en, -- this column is populated later
    NULL::TEXT AS inherited_full_note_en, -- this column is populated later
    NULL::TEXT AS inherited_short_note_es, -- this column is populated later
    NULL::TEXT AS inherited_full_note_es, -- this column is populated later
    NULL::TEXT AS inherited_short_note_fr, -- this column is populated later
    NULL::TEXT AS inherited_full_note_fr, -- this column is populated later
    CASE
    WHEN listing_changes.inclusion_taxon_concept_id IS NOT NULL
    THEN ancestor_listing_auto_note_en(
      inclusion_taxon_concepts, listing_changes
    )
    WHEN applicable_listing_changes.affected_taxon_concept_id != listing_changes.taxon_concept_id
    THEN ancestor_listing_auto_note_en(
      original_taxon_concepts, listing_changes
    )
    ELSE NULL
    END AS auto_note_en,
    CASE
    WHEN listing_changes.inclusion_taxon_concept_id IS NOT NULL
    THEN ancestor_listing_auto_note_es(
      inclusion_taxon_concepts, listing_changes
    )
    WHEN applicable_listing_changes.affected_taxon_concept_id != listing_changes.taxon_concept_id
    THEN ancestor_listing_auto_note_es(
      original_taxon_concepts, listing_changes
    )
    ELSE NULL
    END AS auto_note_es,
    CASE
    WHEN listing_changes.inclusion_taxon_concept_id IS NOT NULL
    THEN ancestor_listing_auto_note_fr(
      inclusion_taxon_concepts, listing_changes
    )
    WHEN applicable_listing_changes.affected_taxon_concept_id != listing_changes.taxon_concept_id
    THEN ancestor_listing_auto_note_fr(
      original_taxon_concepts, listing_changes
    )
    ELSE NULL
    END AS auto_note_fr,
    listing_changes.is_current,
    listing_changes.explicit_change,
    --populations.countries_ids_ary,
    listing_changes.updated_at,
    CASE
    WHEN change_types.name != ''EXCEPTION'' AND listing_changes.explicit_change
    THEN TRUE
    ELSE FALSE
    END AS show_in_history,
    CASE
    WHEN change_types.name != ''EXCEPTION'' AND listing_changes.explicit_change
    THEN TRUE
    ELSE FALSE
    END AS show_in_downloads,
    CASE
    WHEN change_types.name != ''EXCEPTION''
    THEN TRUE
    ELSE FALSE
    END AS show_in_timeline,
    tmp_lc.listed_geo_entities_ids,
    tmp_lc.excluded_geo_entities_ids,
    tmp_lc.excluded_taxon_concept_ids,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM
    applicable_listing_changes
    JOIN listing_changes ON applicable_listing_changes.listing_change_id  = listing_changes.id
    JOIN ' || raw_lc_table_name || ' tmp_lc
    ON applicable_listing_changes.listing_change_id  = tmp_lc.id
    JOIN taxon_concepts original_taxon_concepts
    ON original_taxon_concepts.id = listing_changes.taxon_concept_id
    LEFT JOIN taxon_concepts inclusion_taxon_concepts
    ON inclusion_taxon_concepts.id = listing_changes.inclusion_taxon_concept_id
    INNER JOIN change_types
    ON listing_changes.change_type_id = change_types.id
    INNER JOIN designations
    ON change_types.designation_id = designations.id
    LEFT JOIN species_listings
    ON listing_changes.species_listing_id = species_listings.id
    LEFT JOIN geo_entities ON
    geo_entities.id = tmp_lc.party_id
    LEFT JOIN annotations ON
    annotations.id = listing_changes.annotation_id
    LEFT JOIN annotations hash_annotations ON
    hash_annotations.id = listing_changes.hash_annotation_id
    ORDER BY taxon_concept_id, listing_changes.effective_at,
    CASE
    WHEN change_types.name = ''ADDITION'' THEN 0
    WHEN change_types.name = ''RESERVATION'' THEN 1
    WHEN change_types.name = ''RESERVATION_WITHDRAWAL'' THEN 2
    WHEN change_types.name = ''DELETION'' THEN 3
    END';

    EXECUTE sql;

    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (id, taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (inclusion_taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (taxon_concept_id, original_taxon_concept_id, change_type_id, effective_at)';

    -- now for those taxon concepts that only have inherited legislation,
    -- ignore them in downloads
    sql := 'WITH taxon_concepts_with_inherited_legislation_only AS (
      SELECT taxon_concept_id
      FROM ' || tmp_lc_table_name
      || ' GROUP BY taxon_concept_id
      HAVING EVERY(original_taxon_concept_id != taxon_concept_id)
    )
    UPDATE '|| tmp_lc_table_name || ' listing_changes_mview
    SET show_in_downloads = FALSE
    FROM taxon_concepts_with_inherited_legislation_only
    WHERE taxon_concepts_with_inherited_legislation_only.taxon_concept_id = listing_changes_mview.taxon_concept_id';

    EXECUTE sql;

    SELECT id INTO deletion_id FROM change_types WHERE name = 'DELETION' AND designation_id = designation.id;
    SELECT id INTO addition_id FROM change_types WHERE name = 'ADDITION' AND designation_id = designation.id;
    -- find inherited listing changes superceded by own listing changes
    -- mark them as not current in context of the child and add fake deletion records
    -- so that those inherited events are terminated properly on the timelines
    sql := 'WITH next_lc AS (
      SELECT taxon_concept_id, original_taxon_concept_id, species_listing_id, effective_at
      FROM ' || tmp_lc_table_name
      || ' -- note to self: removed the is_current filter here to also handle cases
      -- where an appendix changed in the past, e.g. Amazona auropalliata
      WHERE change_type_id = ' || addition_id
    || '), prev_lc AS (
      SELECT id,
      listing_changes_mview.original_taxon_concept_id,
      listing_changes_mview.taxon_concept_id,
      next_lc.effective_at,
      listing_changes_mview.species_listing_id,
      species_listing_name,
      designation_id, designation_name,
      party_id, party_iso_code,
      listing_changes_mview.species_listing_id != next_lc.species_listing_id AS appendix_change
      FROM next_lc
      JOIN ' || tmp_lc_table_name || ' listing_changes_mview
      ON listing_changes_mview.taxon_concept_id = next_lc.taxon_concept_id
      AND change_type_id = ' || addition_id
      || ' AND listing_changes_mview.effective_at < next_lc.effective_at
      AND (
        (
          -- own listing change preceded by inherited listing change
          next_lc.original_taxon_concept_id = next_lc.taxon_concept_id
          AND listing_changes_mview.original_taxon_concept_id != listing_changes_mview.taxon_concept_id
        ) OR (
          -- own listing change preceded by own listing change if it is a not current inclusion
          next_lc.original_taxon_concept_id = next_lc.taxon_concept_id
          AND listing_changes_mview.original_taxon_concept_id = listing_changes_mview.taxon_concept_id
          AND listing_changes_mview.inclusion_taxon_concept_id IS NOT NULL
          AND NOT listing_changes_mview.is_current
        ) OR (
          -- inherited listing change preceded by inherited listing change
          next_lc.original_taxon_concept_id != next_lc.taxon_concept_id
          AND listing_changes_mview.original_taxon_concept_id != listing_changes_mview.taxon_concept_id
        ) OR (
          -- inherited listing change preceded by own listing change if it is a not current inclusion
          -- in the same taxon concept as the current listing change
          next_lc.original_taxon_concept_id != next_lc.taxon_concept_id
          AND listing_changes_mview.original_taxon_concept_id = listing_changes_mview.taxon_concept_id
          AND listing_changes_mview.inclusion_taxon_concept_id IS NOT NULL
          AND (
            listing_changes_mview.inclusion_taxon_concept_id = next_lc.original_taxon_concept_id
            OR NOT listing_changes_mview.is_current
          )
        )
      )
    ), fake_deletions AS (
      -- note: this inserts records without an id
      -- this is ok for the timelines, and those records are not used elsewhere
      -- note to self: ids in this view are not unique anyway, since any id
      -- from listing changes can occur multiple times
      INSERT INTO ' || tmp_lc_table_name || ' (
        original_taxon_concept_id, taxon_concept_id,
        effective_at,
        species_listing_id, species_listing_name,
        change_type_id, change_type_name,
        designation_id, designation_name,
        party_id, party_iso_code,
        is_current, explicit_change,
        show_in_timeline, show_in_downloads, show_in_history
      )
      SELECT
      original_taxon_concept_id, taxon_concept_id,
      MIN(effective_at) AS effective_at,
      species_listing_id, species_listing_name, '
      || deletion_id ||', ''DELETION'',
      prev_lc.designation_id, designation_name,
      party_id, party_iso_code,
      TRUE AS is_current, FALSE AS explicit_change,
      TRUE AS show_in_timeline, FALSE AS show_in_downloads, FALSE AS show_in_history
      FROM prev_lc
      WHERE appendix_change
      GROUP BY original_taxon_concept_id, taxon_concept_id,
      species_listing_id, species_listing_name,
      prev_lc.designation_id, designation_name, party_id, party_iso_code
      RETURNING *
    )
    UPDATE ' || tmp_lc_table_name || ' SET is_current = FALSE
    FROM prev_lc terminated_lc
    WHERE terminated_lc.id = ' || tmp_lc_table_name || '.id
    AND terminated_lc.taxon_concept_id = ' || tmp_lc_table_name || '.taxon_concept_id';

    IF designation.name != 'CMS' THEN
      EXECUTE sql;
    END IF;

    -- current inclusions superceded by:
    -- deletions of higher taxa or self
    -- Notomys aquilo, Caracara lutosa, Sceloglaux albifacies
    -- other additions, including appendix transitions
    -- Moschus moschiferus moschiferus

    sql := 'WITH current_inclusions AS (
      SELECT * FROM ' || tmp_lc_table_name || '
      WHERE change_type_name = ''ADDITION''
      AND inclusion_taxon_concept_id IS NOT NULL
      AND is_current
      ), non_current_inclusions AS (
        SELECT current_inclusions.id, current_inclusions.taxon_concept_id
        FROM current_inclusions
        JOIN ' || tmp_lc_table_name || ' lc
        ON lc.change_type_name IN (''ADDITION'', ''DELETION'')
        AND lc.explicit_change
        AND lc.taxon_concept_id = current_inclusions.taxon_concept_id
        AND lc.effective_at > current_inclusions.effective_at
        AND lc.is_current
      )
      UPDATE ' || tmp_lc_table_name || ' lc
      SET is_current = FALSE
      FROM non_current_inclusions
      WHERE lc.id = non_current_inclusions.id
      AND lc.taxon_concept_id = non_current_inclusions.taxon_concept_id';

    EXECUTE sql;

    sql := 'WITH double_inclusions AS (
      SELECT lc.taxon_concept_id, lc.id AS own_inclusion_id, lc_inh.id AS inherited_inclusion_id,
      lc_inh.full_note_en AS inherited_full_note_en,
      lc_inh.short_note_en AS inherited_short_note_en,
      lc_inh.full_note_es AS inherited_full_note_es,
      lc_inh.short_note_es AS inherited_short_note_es,
      lc_inh.full_note_fr AS inherited_full_note_fr,
      lc_inh.short_note_fr AS inherited_short_note_fr
      FROM ' || tmp_lc_table_name || ' lc
      JOIN ' || tmp_lc_table_name || ' lc_inh
      ON lc.taxon_concept_id = lc_inh.taxon_concept_id
      AND lc.species_listing_id = lc_inh.species_listing_id
      AND lc.change_type_id = lc_inh.change_type_id
      AND lc.effective_at = lc_inh.effective_at
      AND (lc.party_id IS NULL OR lc.party_id = lc_inh.party_id)
      AND lc.inclusion_taxon_concept_id = lc_inh.original_taxon_concept_id
      WHERE lc.inclusion_taxon_concept_id IS NOT NULL
    ), rows_to_be_deleted AS (
      DELETE
      FROM ' || tmp_lc_table_name || ' lc
      USING double_inclusions
      WHERE double_inclusions.taxon_concept_id = lc.taxon_concept_id
      AND double_inclusions.inherited_inclusion_id = lc.id
      RETURNING *
    )
    UPDATE ' || tmp_lc_table_name || ' lc
    SET inherited_full_note_en = double_inclusions.inherited_full_note_en,
    inherited_short_note_en = double_inclusions.inherited_short_note_en,
    inherited_full_note_es = double_inclusions.inherited_full_note_es,
    inherited_short_note_es = double_inclusions.inherited_short_note_es,
    inherited_full_note_fr = double_inclusions.inherited_full_note_fr,
    inherited_short_note_fr = double_inclusions.inherited_short_note_fr
    FROM double_inclusions
    WHERE double_inclusions.taxon_concept_id = lc.taxon_concept_id
    AND double_inclusions.own_inclusion_id = lc.id
    AND (double_inclusions.inherited_full_note_en IS NOT NULL OR double_inclusions.inherited_short_note_en IS NOT NULL)';

    EXECUTE sql;

    RAISE INFO 'Creating indexes on %', tmp_lc_table_name;
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (show_in_timeline, taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (show_in_downloads, taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (original_taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (is_current, change_type_name)'; -- Species+ downloads
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' USING GIN (listed_geo_entities_ids)'; -- search by geo entity
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' USING GIN (excluded_geo_entities_ids)'; -- search by geo entity


    RAISE INFO 'Swapping %  materialized view', lc_table_name;
    EXECUTE 'DROP TABLE IF EXISTS ' || lc_table_name || ' CASCADE';
    EXECUTE 'ALTER TABLE ' || tmp_lc_table_name || ' RENAME TO ' || lc_table_name;
  END;
  $$;


--
-- Name: FUNCTION rebuild_designation_listing_changes_mview(taxonomy taxonomies, designation designations, events_ids integer[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_designation_listing_changes_mview(taxonomy taxonomies, designation designations, events_ids integer[]) IS 'Procedure to rebuild designation listing changes materialized view in the database.';


--
-- Name: rebuild_eu_listed_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_eu_listed_status() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_eu_listed_status_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_eu_listed_status(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_eu_listed_status() IS '
  Procedure to rebuild the eu status flags in taxon_concepts.listing.
  1. eu_status
    "LISTED" - explicit/implicit cites listing,
    "DELETED" - taxa previously listed and then deleted
    "EXCLUDED" - taxonomic exceptions
  2. eu_status_original
    TRUE - cites_status is explicit (original)
    FALSE - cites_status is implicit (inherited)
';


--
-- Name: rebuild_eu_listed_status_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_eu_listed_status_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'EU';
    IF NOT FOUND THEN
      RETURN;
    END IF;
    PERFORM rebuild_listing_status_for_designation_and_node(designation, node_id);
    PERFORM set_eu_historically_listed_flag_for_node(node_id);
    END;
  $$;


--
-- Name: rebuild_eu_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_eu_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    --PERFORM rebuild_eu_annotation_symbols_for_node(NULL);
    PERFORM rebuild_eu_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_eu_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_eu_listing() IS 'Procedure to rebuild EU listing in taxon_concepts.';


--
-- Name: rebuild_eu_listing_changes_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_eu_listing_changes_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
    designation designations%ROWTYPE;
    eu_interval RECORD;
    mviews TEXT[];
    sql TEXT;
    tmp_listing_changes_mview TEXT;
    tmp_current_listing_changes_mview TEXT;
    listing_changes_mview TEXT;
  BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'EU';
    IF FOUND THEN
      SELECT * INTO taxonomy FROM taxonomies WHERE id = designation.taxonomy_id;
      PERFORM drop_eu_lc_mviews();
      FOR eu_interval IN (SELECT * FROM eu_regulations_applicability_view) LOOP
        SELECT ARRAY_APPEND(mviews, 'SELECT * FROM ' ||
          listing_changes_mview_name(NULL, designation.name, eu_interval.events_ids)
        ) INTO mviews;
        PERFORM rebuild_designation_all_listing_changes_mview(
          taxonomy, designation, eu_interval.events_ids
        );
        PERFORM rebuild_designation_listing_changes_mview(
          taxonomy, designation, eu_interval.events_ids
        );
        IF eu_interval.end_date IS NULL THEN -- current
          SELECT listing_changes_mview_name('tmp_current', designation.name, NULL)
          INTO tmp_current_listing_changes_mview;
          EXECUTE 'DROP VIEW IF EXISTS ' || tmp_current_listing_changes_mview;
          sql := 'CREATE VIEW ' || tmp_current_listing_changes_mview || ' AS
            SELECT * FROM ' || listing_changes_mview_name('tmp', designation.name, eu_interval.events_ids);
          EXECUTE sql;
        END IF;
      END LOOP;
      SELECT listing_changes_mview_name('tmp_cascaded', designation.name, NULL)
      INTO tmp_listing_changes_mview;
      SELECT listing_changes_mview_name(NULL, designation.name, NULL)
      INTO listing_changes_mview;
      IF ARRAY_UPPER(mviews, 1) IS NULL THEN
        RETURN;
      END IF;
      -- same listing changes might be present in more than one interval
      -- need to DISTINCT
      sql := 'CREATE TABLE ' || tmp_listing_changes_mview || ' AS ' ||
        'SELECT DISTINCT ON (id, taxon_concept_id) * FROM (' || ARRAY_TO_STRING(mviews, ' UNION ') || ') q';
      EXECUTE sql;
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (inclusion_taxon_concept_id)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (taxon_concept_id, original_taxon_concept_id, change_type_id, effective_at)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (show_in_timeline, taxon_concept_id)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (show_in_downloads, taxon_concept_id)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (original_taxon_concept_id)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (is_current, change_type_name)'; -- Species+ downloads
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' USING GIN (listed_geo_entities_ids)'; -- search by geo entity
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' USING GIN (excluded_geo_entities_ids)'; -- search by geo entity

      RAISE INFO 'Swapping eu_listing_changes materialized view';
      EXECUTE 'DROP TABLE IF EXISTS ' || listing_changes_mview || ' CASCADE';
      EXECUTE 'ALTER TABLE ' || tmp_listing_changes_mview || ' RENAME TO ' || listing_changes_mview;
    END IF;
  END;
  $$;


--
-- Name: rebuild_eu_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_eu_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    PERFORM rebuild_eu_listed_status_for_node(node_id);
    PERFORM rebuild_eu_not_listed_status_for_node(node_id);
    --PERFORM rebuild_eu_hash_annotation_symbols_for_node(node_id);
    PERFORM rebuild_explicit_eu_listing_for_node(node_id);
    PERFORM rebuild_ancestor_eu_listing_for_node(node_id);
    END;
  $$;


--
-- Name: rebuild_eu_not_listed_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_eu_not_listed_status() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_eu_not_listed_status_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_eu_not_listed_status(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_eu_not_listed_status() IS '
  Procedure to rebuild the eu_fully_covered AND eu_not_listed flags in taxon_concepts.listing.
  1. eu_fully_covered
    TRUE - all descendants are listed,
    FALSE - some descendants were excluded or deleted from listing
  2. eu_not_listed
    NC - either this taxon or some of its descendants were excluded or deleted from listing
';


--
-- Name: rebuild_eu_not_listed_status_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_eu_not_listed_status_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'EU';
    PERFORM rebuild_not_listed_status_for_designation_and_node(designation, node_id);
    END;
  $$;


--
-- Name: rebuild_eu_species_listing_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_eu_species_listing_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
  
  DROP TABLE IF EXISTS eu_species_listing_mview_tmp;

CREATE TABLE eu_species_listing_mview_tmp AS
SELECT
  taxon_concepts_mview.id AS id,
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.kingdom_id AS kingdom_id,
  taxon_concepts_mview.phylum_id AS phylum_id,
  taxon_concepts_mview.class_id AS class_id,
  taxon_concepts_mview.order_id AS order_id,
  taxon_concepts_mview.family_id AS family_id,
  taxon_concepts_mview.genus_id AS genus_id,
  taxon_concepts_mview.kingdom_name AS kingdom_name,
  taxon_concepts_mview.phylum_name AS phylum_name,
  taxon_concepts_mview.class_name AS class_name,
  taxon_concepts_mview.order_name AS order_name,
  taxon_concepts_mview.family_name AS family_name,
  taxon_concepts_mview.genus_name AS genus_name,
  taxon_concepts_mview.species_name AS species_name,
  taxon_concepts_mview.subspecies_name AS subspecies_name,
  taxon_concepts_mview.full_name AS full_name,
  taxon_concepts_mview.author_year AS author_year,
  taxon_concepts_mview.rank_name AS rank_name,
  taxon_concepts_mview.eu_listed,
  CASE
    WHEN taxon_concepts_mview.eu_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.eu_listing_original) = 0 
    THEN 'NC'
    ELSE taxon_concepts_mview.eu_listing_original
  END AS eu_listing_original,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0 
    THEN 'NC'
    ELSE taxon_concepts_mview.cites_listing_original
  END AS cites_listing_original,
  ARRAY_TO_STRING(
    ARRAY_AGG(DISTINCT listing_changes_mview.party_iso_code),
    ','
  ) AS original_taxon_concept_party_iso_code,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      DISTINCT full_name_with_spp(
        COALESCE(inclusion_taxon_concepts_mview.rank_name, original_taxon_concepts_mview.rank_name),
        COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name)
      )
    ),
    ','
  ) AS original_taxon_concept_full_name_with_spp,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || listing_changes_mview.species_listing_name || '** '
      || CASE 
        WHEN LENGTH(listing_changes_mview.auto_note_en) > 0 THEN '[' || listing_changes_mview.auto_note_en || '] ' 
        ELSE '' 
      END 
      || CASE 
        WHEN LENGTH(listing_changes_mview.inherited_full_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_en) 
        WHEN LENGTH(listing_changes_mview.inherited_short_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_en) 
        WHEN LENGTH(listing_changes_mview.full_note_en) > 0 THEN strip_tags(listing_changes_mview.full_note_en) 
        ELSE strip_tags(listing_changes_mview.short_note_en) 
      END
      ORDER BY listing_changes_mview.species_listing_name
    ),
    E'\n'
  ) AS original_taxon_concept_full_note_en,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || species_listing_name || '** ' || listing_changes_mview.hash_ann_symbol || ' ' 
      || strip_tags(listing_changes_mview.hash_full_note_en)
      ORDER BY species_listing_name
    ),
    E'\n'
  ) AS original_taxon_concept_hash_full_note_en,
  taxon_concepts_mview.countries_ids_ary,
  ARRAY_TO_STRING(taxon_concepts_mview.all_distribution_ary_en, ',') AS all_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.all_distribution_iso_codes_ary, ',') AS all_distribution_iso_codes,
  ARRAY_TO_STRING(taxon_concepts_mview.native_distribution_ary_en, ',') AS native_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.introduced_distribution_ary_en, ',') AS introduced_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.introduced_uncertain_distribution_ary_en, ',') AS introduced_uncertain_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.reintroduced_distribution_ary_en, ',') AS reintroduced_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.extinct_distribution_ary_en, ',') AS extinct_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.extinct_uncertain_distribution_ary_en, ',') AS extinct_uncertain_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.uncertain_distribution_ary_en, ',') AS uncertain_distribution
FROM "taxon_concepts_mview"
JOIN eu_listing_changes_mview listing_changes_mview
  ON listing_changes_mview.taxon_concept_id = taxon_concepts_mview.id
  AND is_current
  AND change_type_name = 'ADDITION'
JOIN taxon_concepts_mview original_taxon_concepts_mview
  ON listing_changes_mview.original_taxon_concept_id = original_taxon_concepts_mview.id
LEFT JOIN taxon_concepts_mview inclusion_taxon_concepts_mview
  ON listing_changes_mview.inclusion_taxon_concept_id = inclusion_taxon_concepts_mview.id 
WHERE "taxon_concepts_mview"."name_status" = 'A'
  AND "taxon_concepts_mview".taxonomy_is_cites_eu = TRUE
  AND "taxon_concepts_mview"."eu_show" = 't' 
  AND "taxon_concepts_mview"."rank_name" IN ('SPECIES', 'SUBSPECIES', 'VARIETY')
  AND (taxon_concepts_mview.eu_listing_original != 'NC') 
GROUP BY
  taxon_concepts_mview.id,
  taxon_concepts_mview.kingdom_id,
  taxon_concepts_mview.phylum_id,
  taxon_concepts_mview.class_id,
  taxon_concepts_mview.order_id,
  taxon_concepts_mview.family_id,
  taxon_concepts_mview.genus_id,
  taxon_concepts_mview.kingdom_name,
  taxon_concepts_mview.phylum_name,
  taxon_concepts_mview.class_name,
  taxon_concepts_mview.order_name,
  taxon_concepts_mview.family_name,
  taxon_concepts_mview.genus_name,
  taxon_concepts_mview.species_name,
  taxon_concepts_mview.subspecies_name,
  taxon_concepts_mview.full_name,
  taxon_concepts_mview.author_year,
  taxon_concepts_mview.rank_name,
  taxon_concepts_mview.eu_listed,
  CASE
    WHEN taxon_concepts_mview.eu_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.eu_listing_original) = 0 
    THEN 'NC' ELSE taxon_concepts_mview.eu_listing_original
  END,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL 
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0 
    THEN 'NC'
    ELSE taxon_concepts_mview.cites_listing_original
  END,
  COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name),
  COALESCE(inclusion_taxon_concepts_mview.spp, original_taxon_concepts_mview.spp),
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.countries_ids_ary,
  taxon_concepts_mview.all_distribution_ary_en,
  taxon_concepts_mview.all_distribution_iso_codes_ary,
  taxon_concepts_mview.native_distribution_ary_en,
  taxon_concepts_mview.introduced_distribution_ary_en,
  taxon_concepts_mview.introduced_uncertain_distribution_ary_en,
  taxon_concepts_mview.reintroduced_distribution_ary_en,
  taxon_concepts_mview.extinct_distribution_ary_en,
  taxon_concepts_mview.extinct_uncertain_distribution_ary_en,
  taxon_concepts_mview.uncertain_distribution_ary_en;

  CREATE INDEX ON eu_species_listing_mview_tmp USING GIN (countries_ids_ary); -- search by geo entity

  DROP TABLE IF EXISTS eu_species_listing_mview;
  ALTER TABLE eu_species_listing_mview_tmp RENAME TO eu_species_listing_mview;

END;
$$;


--
-- Name: rebuild_explicit_cites_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_explicit_cites_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
      PERFORM rebuild_explicit_cites_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_explicit_cites_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_explicit_cites_listing() IS '
Procedure to rebuild explicit CITES listing in taxon_concepts.
';


--
-- Name: rebuild_explicit_cites_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_explicit_cites_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN

    UPDATE taxon_concepts SET listing =
    CASE
    WHEN NOT (taxon_concepts.listing->'cites_status_original')::BOOLEAN
    THEN taxon_concepts.listing - ARRAY['cites_not_listed']
    ELSE taxon_concepts.listing
    END || qqq.listing
    FROM (
      SELECT taxon_concept_id, listing ||
      hstore('cites_listing_original', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[
            listing -> 'cites_I', listing -> 'cites_II', listing -> 'cites_III',
            listing -> 'cites_not_listed'
          ]
        ) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM (
        SELECT taxon_concept_id, 
        CASE 
          WHEN BOOL_OR(species_listing_name = 'I') 
          THEN hstore('cites_I', 'I') ELSE hstore('cites_I', NULL)
        END || 
        CASE
          WHEN BOOL_OR(species_listing_name = 'II') 
          THEN hstore('cites_II', 'II') ELSE hstore('cites_II', NULL)
        END ||
        CASE
          WHEN BOOL_OR(species_listing_name = 'III') 
          THEN hstore('cites_III', 'III') ELSE hstore('cites_III', NULL)
        END AS listing
        FROM cites_listing_changes_mview
        WHERE change_type_name = 'ADDITION' AND is_current
        GROUP BY taxon_concept_id
      ) AS qq
    ) AS qqq
    WHERE taxon_concepts.id = qqq.taxon_concept_id AND
    CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;
    END;
  $$;


--
-- Name: rebuild_explicit_cms_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_explicit_cms_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    PERFORM rebuild_explicit_cms_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_explicit_cms_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_explicit_cms_listing() IS '
Procedure to rebuild explicit CMS listing in taxon_concepts.
';


--
-- Name: rebuild_explicit_cms_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_explicit_cms_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    UPDATE taxon_concepts SET listing =
    CASE
    WHEN NOT (taxon_concepts.listing->'cms_status_original')::BOOLEAN
    THEN taxon_concepts.listing - ARRAY['cms_not_listed']
    ELSE taxon_concepts.listing
    END || qqq.listing
    FROM (
      SELECT taxon_concept_id, listing ||
      hstore('cms_listing_original', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[
            listing -> 'cms_I', listing -> 'cms_II',
            listing -> 'cms_not_listed'
          ]
        ) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM (
        SELECT taxon_concept_id,
        CASE 
          WHEN BOOL_OR(species_listing_name = 'I') 
          THEN hstore('cms_I', 'I') ELSE hstore('cms_I', NULL)
        END || 
        CASE
          WHEN BOOL_OR(species_listing_name = 'II') 
          THEN hstore('cms_II', 'II') ELSE hstore('cms_II', NULL)
        END AS listing
        FROM cms_listing_changes_mview
        WHERE change_type_name = 'ADDITION' AND is_current
        GROUP BY taxon_concept_id
      ) AS qq
    ) AS qqq
    WHERE taxon_concepts.id = qqq.taxon_concept_id AND
    CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;
    END;
  $$;


--
-- Name: rebuild_explicit_eu_listing(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_explicit_eu_listing() RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    PERFORM rebuild_explicit_eu_listing_for_node(NULL);
    END;
  $$;


--
-- Name: FUNCTION rebuild_explicit_eu_listing(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_explicit_eu_listing() IS '
Procedure to rebuild explicit EU listing in taxon_concepts.
';


--
-- Name: rebuild_explicit_eu_listing_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_explicit_eu_listing_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    BEGIN
    UPDATE taxon_concepts SET listing =
    CASE
    WHEN NOT (taxon_concepts.listing->'eu_status_original')::BOOLEAN
    THEN taxon_concepts.listing - ARRAY['eu_not_listed']
    ELSE taxon_concepts.listing
    END || qqq.listing
    FROM (
      SELECT taxon_concept_id, listing ||
      hstore('eu_listing_original', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[
            listing -> 'eu_A', listing -> 'eu_B', listing -> 'eu_C',
            listing -> 'eu_D', listing -> 'eu_not_listed'
          ]
        ) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM (
        SELECT taxon_concept_id,
        CASE 
          WHEN BOOL_OR(species_listing_name = 'A') 
          THEN hstore('eu_A', 'A') ELSE hstore('eu_A', NULL)
        END || 
        CASE 
          WHEN BOOL_OR(species_listing_name = 'B') 
          THEN hstore('eu_B', 'B') ELSE hstore('eu_B', NULL)
        END || 
        CASE 
          WHEN BOOL_OR(species_listing_name = 'C') 
          THEN hstore('eu_C', 'C') ELSE hstore('eu_C', NULL)
        END || 
        CASE
          WHEN BOOL_OR(species_listing_name = 'D') 
          THEN hstore('eu_D', 'D') ELSE hstore('eu_D', NULL)
        END AS listing
        FROM eu_listing_changes_mview
        WHERE change_type_name = 'ADDITION' AND is_current
        GROUP BY taxon_concept_id
      ) AS qq
    ) AS qqq
    WHERE taxon_concepts.id = qqq.taxon_concept_id AND
    CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;
    END;
  $$;


--
-- Name: rebuild_listing_changes_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_listing_changes_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    PERFORM rebuild_cites_eu_taxon_concepts_and_ancestors_mview();
    PERFORM rebuild_cms_taxon_concepts_and_ancestors_mview();
    PERFORM rebuild_cites_listing_changes_mview();
    PERFORM rebuild_eu_listing_changes_mview();
    PERFORM rebuild_cms_listing_changes_mview();
  END;
  $$;


--
-- Name: FUNCTION rebuild_listing_changes_mview(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_listing_changes_mview() IS 'Procedure to rebuild listing changes materialized view in the database.';


--
-- Name: rebuild_listing_status_for_designation_and_node(designations, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_listing_status_for_designation_and_node(designation designations, node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      deletion_id int;
      addition_id int;
      exception_id int;
      designation_name TEXT;
      status_flag varchar;
      status_original_flag varchar;
      listing_original_flag varchar;
      listing_flag varchar;
      listing_updated_at_flag varchar;
      not_listed_flag varchar;
      show_flag varchar;
      level_of_listing_flag varchar;
      flags_to_reset text[];
      sql TEXT;
      tmp_current_listing_changes_mview TEXT;
    BEGIN
    SELECT id INTO deletion_id FROM change_types
      WHERE designation_id = designation.id AND name = 'DELETION';
    SELECT id INTO addition_id FROM change_types
      WHERE designation_id = designation.id AND name = 'ADDITION';
    SELECT id INTO exception_id FROM change_types
      WHERE designation_id = designation.id AND name = 'EXCEPTION';
    designation_name = LOWER(designation.name);
    status_flag = designation_name || '_status';
    status_original_flag = designation_name || '_status_original';
    listing_original_flag := designation_name || '_listing_original';
    listing_flag := designation_name || '_listing';
    listing_updated_at_flag = designation_name || '_updated_at';
    level_of_listing_flag := designation_name || '_level_of_listing';
    not_listed_flag := designation_name || '_not_listed';
    show_flag := designation_name || '_show';
    
    
    flags_to_reset := ARRAY[
      status_flag, status_original_flag, listing_flag, listing_original_flag, 
      not_listed_flag, listing_updated_at_flag, level_of_listing_flag,
      show_flag
    ];
    IF designation.name = 'CITES' THEN
      flags_to_reset := flags_to_reset ||
        ARRAY['cites_I','cites_II','cites_III'];
    ELSIF designation.name = 'EU' THEN
      flags_to_reset := flags_to_reset ||
        ARRAY['eu_A','eu_B','eu_C','eu_D'];
    ELSIF designation.name = 'CMS' THEN
      flags_to_reset := flags_to_reset ||
        ARRAY['cms_I','cms_II'];
    END IF;

    -- reset the listing status (so we start clear)
    UPDATE taxon_concepts
    SET listing = (COALESCE(listing, ''::HSTORE) - flags_to_reset)
    WHERE taxonomy_id = designation.taxonomy_id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    -- set status property to 'LISTED' for all explicitly listed taxa
    -- i.e. ones which have at least one current ADDITION
    -- that is not an inclusion
    -- also set status_original & level_of_listing flags to true
    -- also set the listing_updated_at property
    WITH listed_taxa AS (
      SELECT taxon_concepts.id, MAX(effective_at) AS listing_updated_at
      FROM taxon_concepts
      INNER JOIN listing_changes
        ON taxon_concepts.id = listing_changes.taxon_concept_id
        AND is_current = 't'
        AND change_type_id = addition_id
      WHERE taxonomy_id = designation.taxonomy_id
      AND inclusion_taxon_concept_id IS NULL
      GROUP BY taxon_concepts.id
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_flag, 'LISTED') ||
      hstore(status_original_flag, 't') ||
      hstore(level_of_listing_flag, 't') ||
      hstore(listing_updated_at_flag, listing_updated_at::VARCHAR) 
    FROM listed_taxa
    WHERE taxon_concepts.id = listed_taxa.id AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- set status property to 'EXCLUDED' for all explicitly excluded taxa
    -- omit ones already marked as listed
    -- also set status_original flag to true
    -- note: this was moved before setting the "deleted" status,
    -- because some taxa were deleted but still need to show up
    -- in the checklist, and so they get the "excluded" status
    -- to differentiate them
    WITH excluded_taxa AS (
      WITH listing_exceptions AS (
        SELECT listing_changes.parent_id, taxon_concept_id
        FROM listing_changes
        INNER JOIN taxon_concepts
          ON listing_changes.taxon_concept_id  = taxon_concepts.id
            AND taxonomy_id = designation.taxonomy_id
            AND (
              listing -> status_flag <> 'LISTED'
              OR (listing -> status_flag)::VARCHAR IS NULL
            )
        WHERE change_type_id = exception_id
      )
      SELECT DISTINCT listing_exceptions.taxon_concept_id AS id
      FROM listing_exceptions
      INNER JOIN listing_changes
        ON listing_changes.id = listing_exceptions.parent_id
          AND listing_changes.taxon_concept_id <> listing_exceptions.taxon_concept_id
          AND listing_changes.change_type_id = addition_id
          AND listing_changes.is_current = TRUE
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_flag, 'EXCLUDED') ||
      hstore(status_original_flag, 't')
    FROM excluded_taxa
    WHERE taxon_concepts.id = excluded_taxa.id AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- set status property to 'DELETED' for all explicitly deleted taxa
    -- omit ones already marked as listed (applies to appendix III deletions)
    -- also set status_original flag to true
    -- also set a flag if there are listed subspecies of a deleted species
    WITH deleted_taxa AS (
      SELECT taxon_concepts.id
      FROM taxon_concepts
      INNER JOIN listing_changes
        ON taxon_concepts.id = listing_changes.taxon_concept_id
        AND is_current = 't' AND change_type_id = deletion_id
      WHERE taxonomy_id = designation.taxonomy_id AND (
        listing -> status_flag <> 'LISTED'
        AND listing -> status_flag <> 'EXCLUDED'
          OR (listing -> status_flag)::VARCHAR IS NULL
      )
    ), not_really_deleted_taxa AS (
      -- crazy stuff to do with species that were deleted but have listed subspecies
      -- so in fact this is really confusing but what can you do, flag it
        SELECT DISTINCT parent_id AS id
        FROM taxon_concepts
        JOIN deleted_taxa
        ON taxon_concepts.parent_id = deleted_taxa.id
        JOIN ranks
        ON taxon_concepts.rank_id = ranks.id AND ranks.name = 'SUBSPECIES'
        WHERE taxon_concepts.listing->status_flag = 'LISTED'
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_flag, 'DELETED') ||
      hstore(status_original_flag, 't') ||
      hstore(
        'not_really_deleted',
        CASE WHEN not_really_deleted_taxa.id IS NOT NULL THEN 't'
        ELSE 'f' END
      )
    FROM deleted_taxa
    LEFT JOIN not_really_deleted_taxa
    ON not_really_deleted_taxa.id = deleted_taxa.id
    WHERE taxon_concepts.id = deleted_taxa.id AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- propagate cites_status to descendants
    SELECT listing_changes_mview_name('tmp_current', designation.name, NULL)
    INTO tmp_current_listing_changes_mview;

    sql := 'WITH RECURSIVE q AS (
      SELECT
        h.id,
        h.parent_id,
        listing->''' || designation_name || '_status'' AS inherited_status,
        listing->''' || designation_name || '_updated_at'' AS inherited_listing_updated_at,
        listed_geo_entities_ids,
        excluded_geo_entities_ids,
        excluded_taxon_concept_ids,
        HSTORE(''' || designation_name || '_status_original'', ''t'') || 
        CASE 
          WHEN lc.change_type_name = ''DELETION''
          THEN HSTORE(''' || designation_name || '_status'',  ''DELETED'') || 
            HSTORE(''' || designation_name || '_not_listed'', ''NC'')
          ELSE HSTORE(''' || designation_name || '_status'',  ''LISTED'') || 
            HSTORE(''' || designation_name || '_not_listed'', NULL)
        END AS status_hstore
      FROM    taxon_concepts h
      JOIN ' || tmp_current_listing_changes_mview || ' lc
      ON h.id = lc.taxon_concept_id
      AND lc.change_type_name IN (''ADDITION'', ''DELETION'')
      AND inclusion_taxon_concept_id IS NULL
      GROUP BY
        h.id,
        listed_geo_entities_ids,
        excluded_geo_entities_ids,
        excluded_taxon_concept_ids,
        lc.change_type_name

      UNION

      SELECT
        hi.id,
        hi.parent_id,
        inherited_status,
        inherited_listing_updated_at,
        listed_geo_entities_ids,
        excluded_geo_entities_ids,
        excluded_taxon_concept_ids,
        CASE
        WHEN (hi.listing->''' || designation_name || '_status_original'')::BOOLEAN
        THEN SLICE(hi.listing, ARRAY[
          ''' || designation_name || '_status_original'', 
          ''' || designation_name || '_status'', 
          ''' || designation_name || '_level_of_listing'',
          ''' || designation_name || '_updated_at'', 
          ''' || designation_name || '_not_listed''
        ])
        ELSE
          HSTORE(''' || designation_name || '_status_original'', ''f'') ||
            HSTORE(''' || designation_name || '_level_of_listing'', ''f'') ||
            CASE
              WHEN ARRAY_UPPER(excluded_taxon_concept_ids, 1) IS NOT NULL 
                AND excluded_taxon_concept_ids @> ARRAY[hi.id]
              THEN HSTORE(''' || designation_name || '_status'', ''EXCLUDED'') || 
                HSTORE(''' || designation_name || '_not_listed'', ''NC'')
              WHEN ARRAY_UPPER(excluded_geo_entities_ids, 1) IS NOT NULL 
                AND EXISTS (
                SELECT 1 FROM distributions
                WHERE q.excluded_geo_entities_ids @> ARRAY[geo_entity_id]
                  AND taxon_concept_id = hi.id
              )
              THEN HSTORE(''' || designation_name || '_status'', ''EXCLUDED'') ||
                HSTORE(''' || designation_name || '_not_listed'', ''NC'')
              WHEN ARRAY_UPPER(listed_geo_entities_ids, 1) IS NOT NULL 
                AND NOT EXISTS (
                SELECT 1 FROM distributions
                WHERE q.listed_geo_entities_ids @> ARRAY[geo_entity_id]
                  AND taxon_concept_id = hi.id
              )
              THEN HSTORE(''' || designation_name || '_status'', NULL) ||
                HSTORE(''' || designation_name || '_not_listed'', ''NC'')
              ELSE HSTORE(
                ''' || designation_name || '_status'',
                q.status_hstore->''' || designation_name || '_status''
              ) || HSTORE(
              ''' || designation_name || '_not_listed'',
              q.status_hstore->''' || designation_name || '_not_listed''
              )
            END
        END
      FROM q
      JOIN taxon_concepts hi
        ON hi.parent_id = q.id      
    ), grouped AS (
      SELECT id, 
      HSTORE(
        ''' || designation_name || '_status'',
        CASE
          WHEN BOOL_OR(status_hstore->''' || designation_name || '_status'' = ''LISTED'')
          THEN ''LISTED''
          ELSE MAX(status_hstore->''' || designation_name || '_status'')
        END
      ) ||
      HSTORE(
        ''' || designation_name || '_status_original'',
        BOOL_OR((status_hstore->''' || designation_name || '_status_original'')::BOOLEAN)::TEXT
      ) ||
      HSTORE(
        ''' || designation_name || '_not_listed'',
        CASE
          WHEN BOOL_AND(status_hstore->''' || designation_name || '_not_listed'' = ''NC'')
          THEN ''NC''
          ELSE NULL
        END
      ) ||
      HSTORE(
        ''' || designation_name || '_updated_at'',
        MAX(inherited_listing_updated_at)
      ) AS status_hstore
    FROM q
    GROUP BY q.id --this grouping is to accommodate for split listings
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''''::HSTORE) || grouped.status_hstore
    FROM grouped
    WHERE taxon_concepts.id = grouped.id';

    EXECUTE sql;

    -- set cites_status property to 'LISTED' for ancestors of listed taxa
    WITH qq AS (
      WITH RECURSIVE q AS
      (
        SELECT  h.id, h.parent_id,
        listing->status_flag AS inherited_status,
        (listing->listing_updated_at_flag)::TIMESTAMP AS inherited_listing_updated_at
        FROM    taxon_concepts h
        WHERE
          listing->status_flag = 'LISTED'
          AND (listing->status_original_flag)::BOOLEAN = 't'
          AND
          CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END

        UNION

        SELECT  hi.id, hi.parent_id,
        CASE
          WHEN (listing->status_original_flag)::BOOLEAN = 't'
          THEN listing->status_flag
          ELSE inherited_status
        END,
        CASE
          WHEN (listing->listing_updated_at_flag)::TIMESTAMP IS NOT NULL
          THEN (listing->listing_updated_at_flag)::TIMESTAMP
          ELSE inherited_listing_updated_at
        END
        FROM    q
        JOIN    taxon_concepts hi
        ON      hi.id = q.parent_id
        WHERE (listing->status_original_flag)::BOOLEAN IS NULL
      )
      SELECT DISTINCT id, inherited_status,
        inherited_listing_updated_at
      FROM q
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
      hstore(status_flag, inherited_status) ||
      hstore(status_original_flag, 'f') ||
      hstore(level_of_listing_flag, 'f') ||
      hstore(listing_updated_at_flag, inherited_listing_updated_at::VARCHAR)
    FROM qq
    WHERE taxon_concepts.id = qq.id
     AND (
       listing IS NULL
       OR (listing->status_original_flag)::BOOLEAN IS NULL
       OR (listing->status_original_flag)::BOOLEAN = 'f'
     );

    END;
  $$;


--
-- Name: rebuild_mviews(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_mviews() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    PERFORM rebuild_taxon_concepts_mview();
    PERFORM rebuild_listing_changes_mview();
  END;
  $$;


--
-- Name: FUNCTION rebuild_mviews(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_mviews() IS 'Procedure to rebuild materialized views in the database.';


--
-- Name: rebuild_not_listed_status_for_designation_and_node(designations, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_not_listed_status_for_designation_and_node(designation designations, node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
      exception_id int;
      fully_covered_flag varchar;
      not_listed_flag varchar;
      status_original_flag varchar;
      status_flag varchar;
      listing_original_flag varchar;
      listing_flag varchar;
      listed_ancestors_flag varchar;
      ancestor_node_ids INTEGER[];
      show_flag varchar;
    BEGIN
    SELECT id INTO exception_id FROM change_types
      WHERE designation_id = designation.id AND name = 'EXCEPTION';

    fully_covered_flag := LOWER(designation.name) || '_fully_covered';
    not_listed_flag := LOWER(designation.name) || '_not_listed';
    status_original_flag := LOWER(designation.name) || '_status_original';
    status_flag = LOWER(designation.name) || '_status';
    listing_original_flag := LOWER(designation.name) || '_listing_original';
    listing_flag := LOWER(designation.name) || '_listing';
    listed_ancestors_flag := LOWER(designation.name) || '_listed_ancestors';
    show_flag := LOWER(designation.name) || '_show';

    -- reset the fully_covered flag (so we start clear)
    -- also set the listed ancestors flag to true
    UPDATE taxon_concepts SET listing = listing - ARRAY[not_listed_flag] ||
      hstore(fully_covered_flag, 't') ||
      hstore(listed_ancestors_flag, 't')
    WHERE
      taxonomy_id = designation.taxonomy_id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    -- set the fully_covered flag to false for taxa
    -- that were deleted or excluded from the listing
    WITH deleted_or_excluded AS (
      SELECT id,
        CASE
          WHEN (listing->status_flag)::VARCHAR = 'DELETED'
            OR (listing->status_flag)::VARCHAR = 'EXCLUDED'
          THEN 't'
          ELSE 'f'
        END AS not_listed
      FROM taxon_concepts
      WHERE
        taxonomy_id = designation.taxonomy_id
        AND listing->status_flag IN ('DELETED', 'EXCLUDED')
        AND CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END
    )
    UPDATE taxon_concepts
    SET listing = listing ||
      hstore(fully_covered_flag, 'f') ||
      hstore(listing_original_flag, 'NC')
    FROM deleted_or_excluded
    WHERE taxon_concepts.id = deleted_or_excluded.id;

    -- set the fully_covered flag to false for taxa
    -- that only have some populations listed

    WITH incomplete_distributions AS (
      SELECT taxon_concept_id AS id FROM listing_distributions
      INNER JOIN listing_changes
        ON listing_changes.id = listing_distributions.listing_change_id
      INNER JOIN change_types
        ON change_types.id = listing_changes.change_type_id 
        AND change_types.designation_id = designation.id
        AND change_types.name = 'ADDITION'
      WHERE is_current = 't'
        AND NOT listing_distributions.is_party
        AND CASE WHEN node_id IS NOT NULL THEN listing_changes.taxon_concept_id = node_id ELSE TRUE END

      EXCEPT

      SELECT taxon_concept_id AS id FROM listing_distributions
      RIGHT JOIN listing_changes
        ON listing_changes.id = listing_distributions.listing_change_id
      INNER JOIN taxon_concepts
        ON taxon_concepts.id = listing_changes.taxon_concept_id
      WHERE is_current = 't' AND taxonomy_id = designation.taxonomy_id
        AND (listing_distributions.id IS NULL OR listing_distributions.is_party)
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(fully_covered_flag, 'f')
    FROM incomplete_distributions
    WHERE taxon_concepts.id = incomplete_distributions.id;

    -- set the fully_covered flag to false for taxa
    -- that do not have a cascaded listing
    -- also set the 'has_listed_ancestors' flag to false

    WITH RECURSIVE taxa_without_cascaded_listing AS (
      SELECT id
      FROM taxon_concepts 
      WHERE taxonomy_id = designation.taxonomy_id
        AND parent_id IS NULL

      UNION

      SELECT hi.id
      FROM taxon_concepts hi
      JOIN taxa_without_cascaded_listing
      ON taxa_without_cascaded_listing.id = hi.parent_id
      AND NOT (hi.listing->status_original_flag)::BOOLEAN
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(fully_covered_flag, 'f') || hstore(listed_ancestors_flag, 'f')
    FROM taxa_without_cascaded_listing
    WHERE taxon_concepts.id = taxa_without_cascaded_listing.id
      AND NOT (listing->status_original_flag)::BOOLEAN
      AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- propagate the fully_covered flag to ancestors
    -- update the nc flag for all that are not fully covered
    WITH RECURSIVE not_fully_covered AS (
      SELECT id, parent_id
      FROM taxon_concepts
      WHERE taxonomy_id = designation.taxonomy_id
        AND NOT (listing->fully_covered_flag)::BOOLEAN
        AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END

      UNION

      SELECT h.id, h.parent_id
      FROM taxon_concepts h
      JOIN not_fully_covered
      ON h.id = not_fully_covered.parent_id
    )
    UPDATE taxon_concepts
    SET listing = listing ||
      hstore(fully_covered_flag, 'f') || hstore(not_listed_flag, 'NC')
    FROM not_fully_covered
    WHERE taxon_concepts.id = not_fully_covered.id;

    -- update the nc flags for all leftovers
    UPDATE taxon_concepts
    SET listing = listing ||
    hstore(not_listed_flag, 'NC') || hstore(listing_original_flag, 'NC') || hstore(listing_flag, 'NC')
    WHERE taxonomy_id = designation.taxonomy_id 
      AND (listing->status_flag)::VARCHAR IS NULL
      AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    IF node_id IS NOT NULL THEN
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
    END IF;

    -- set designation_show to true for all taxa except:
    -- implicitly listed subspecies
    -- hybrids
    -- excluded and not listed taxa
    -- higher taxa (incl. genus) that do not have a cascaded listing
    UPDATE taxon_concepts SET listing = listing ||
    CASE
      WHEN name_status = 'H'
      THEN hstore(show_flag, 'f')
      WHEN (
        data->'rank_name' = 'SUBSPECIES'
        OR data->'rank_name' = 'VARIETY'
      )
      AND listing->status_flag = 'LISTED'
      AND (listing->status_original_flag)::BOOLEAN = FALSE
      THEN hstore(show_flag, 'f')  
      WHEN NOT (
        data->'rank_name' = 'SPECIES'
      )
      AND listing->status_flag = 'LISTED'
      AND (listing->status_original_flag)::BOOLEAN = FALSE
      AND (listing->listed_ancestors_flag)::BOOLEAN = FALSE
      THEN hstore(show_flag, 'f')
      WHEN listing->status_flag = 'EXCLUDED'
      THEN hstore(show_flag, 't')
      WHEN listing->status_flag = 'DELETED'
        AND (listing->'not_really_deleted')::BOOLEAN = TRUE
      THEN hstore(show_flag, 't')
      WHEN listing->status_flag = 'DELETED'
        OR (listing->status_flag)::VARCHAR IS NULL
      THEN hstore(show_flag, 'f')
      ELSE hstore(show_flag, 't')
    END
    WHERE taxonomy_id = designation.taxonomy_id AND
    CASE WHEN node_id IS NOT NULL THEN id IN (SELECT id FROM UNNEST(ancestor_node_ids)) ELSE TRUE END;

    END;
  $$;


--
-- Name: rebuild_taxon_concepts_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxon_concepts_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    DROP table IF EXISTS taxon_concepts_mview_tmp CASCADE;
    DROP view IF EXISTS taxon_concepts_view_tmp;

    CREATE OR REPLACE VIEW taxon_concepts_view_tmp AS
    SELECT taxon_concepts.id,
    taxon_concepts.parent_id,
    taxon_concepts.taxonomy_id,
    CASE
    WHEN taxonomies.name = 'CITES_EU' THEN TRUE
    ELSE FALSE
    END AS taxonomy_is_cites_eu,
    full_name,
    name_status,
    rank_id,
    ranks.name AS rank_name,
    ranks.display_name_en AS rank_display_name_en,
    ranks.display_name_es AS rank_display_name_es,
    ranks.display_name_fr AS rank_display_name_fr,
    (data->'spp')::BOOLEAN AS spp,
    (data->'cites_accepted')::BOOLEAN AS cites_accepted,
    CASE
    WHEN data->'kingdom_name' = 'Animalia' THEN 0
    ELSE 1
    END AS kingdom_position,
    taxon_concepts.taxonomic_position,
    data->'kingdom_name' AS kingdom_name,
    data->'phylum_name' AS phylum_name,
    data->'class_name' AS class_name,
    data->'order_name' AS order_name,
    data->'family_name' AS family_name,
    data->'subfamily_name' AS subfamily_name,
    data->'genus_name' AS genus_name,
    LOWER(data->'species_name') AS species_name,
    LOWER(data->'subspecies_name') AS subspecies_name,
    (data->'kingdom_id')::INTEGER AS kingdom_id,
    (data->'phylum_id')::INTEGER AS phylum_id,
    (data->'class_id')::INTEGER AS class_id,
    (data->'order_id')::INTEGER AS order_id,
    (data->'family_id')::INTEGER AS family_id,
    (data->'subfamily_id')::INTEGER AS subfamily_id,
    (data->'genus_id')::INTEGER AS genus_id,
    (data->'species_id')::INTEGER AS species_id,
    (data->'subspecies_id')::INTEGER AS subspecies_id,
    CASE
    WHEN listing->'cites_I' = 'I' THEN TRUE
    ELSE FALSE
    END AS cites_I,
    CASE
    WHEN listing->'cites_II' = 'II' THEN TRUE
    ELSE FALSE
    END AS cites_II,
    CASE
    WHEN listing->'cites_III' = 'III' THEN TRUE
    ELSE FALSE
    END AS cites_III,
    CASE
    WHEN listing->'cites_status' = 'LISTED' AND listing->'cites_level_of_listing' = 't'
    THEN TRUE
    WHEN listing->'cites_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
    END AS cites_listed,
    (listing->'cites_listed_descendants')::BOOLEAN AS cites_listed_descendants,
    (listing->'cites_show')::BOOLEAN AS cites_show,
    --(listing->'cites_status_original')::BOOLEAN AS cites_status_original, --doesn't seem to be used
    listing->'cites_status' AS cites_status,
    listing->'cites_listing_original' AS cites_listing_original, --used in CSV downloads
    listing->'cites_listing' AS cites_listing,
    (listing->'cites_listing_updated_at')::TIMESTAMP AS cites_listing_updated_at,
    (listing->'ann_symbol') AS ann_symbol,
    (listing->'hash_ann_symbol') AS hash_ann_symbol,
    (listing->'hash_ann_parent_symbol') AS hash_ann_parent_symbol,
    CASE
    WHEN listing->'eu_status' = 'LISTED' AND listing->'eu_level_of_listing' = 't'
    THEN TRUE
    WHEN listing->'eu_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
    END AS eu_listed,
    (listing->'eu_show')::BOOLEAN AS eu_show,
    --(listing->'eu_status_original')::BOOLEAN AS eu_status_original, --doesn't seem to be used
    listing->'eu_status' AS eu_status,
    listing->'eu_listing_original' AS eu_listing_original,
    listing->'eu_listing' AS eu_listing,
    (listing->'eu_listing_updated_at')::TIMESTAMP AS eu_listing_updated_at,
    CASE
    WHEN listing->'cms_status' = 'LISTED' AND listing->'cms_level_of_listing' = 't'
    THEN TRUE
    WHEN listing->'cms_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
    END AS cms_listed,
    (listing->'cms_show')::BOOLEAN AS cms_show,
    listing->'cms_status' AS cms_status,
    listing->'cms_listing_original' AS cms_listing_original,
    listing->'cms_listing' AS cms_listing,
    (listing->'cms_listing_updated_at')::TIMESTAMP AS cms_listing_updated_at,
    (listing->'species_listings_ids')::INT[] AS species_listings_ids,
    (listing->'species_listings_ids_aggregated')::INT[] AS species_listings_ids_aggregated,
    author_year,
    taxon_concepts.created_at,
    taxon_concepts.updated_at,
    taxon_concepts.dependents_updated_at,
    common_names.*,
    synonyms.*,
    subspecies.subspecies_not_listed_ary,
    countries_ids_ary,
    all_distribution_iso_codes_ary,
    -- BEGIN remove once checklist translation has been deployed
    all_distribution_ary_en AS all_distribution_ary,
    native_distribution_ary_en AS native_distribution_ary,
    introduced_distribution_ary_en AS introduced_distribution_ary,
    introduced_uncertain_distribution_ary_en AS introduced_uncertain_distribution_ary,
    reintroduced_distribution_ary_en AS reintroduced_distribution_ary,
    extinct_distribution_ary_en AS extinct_distribution_ary,
    extinct_uncertain_distribution_ary_en AS extinct_uncertain_distribution_ary,
    uncertain_distribution_ary_en AS uncertain_distribution_ary,
    -- END remove once checklist translation has been deployed
    all_distribution_ary_en,
    native_distribution_ary_en,
    introduced_distribution_ary_en,
    introduced_uncertain_distribution_ary_en,
    reintroduced_distribution_ary_en,
    extinct_distribution_ary_en,
    extinct_uncertain_distribution_ary_en,
    uncertain_distribution_ary_en,
    all_distribution_ary_es,
    native_distribution_ary_es,
    introduced_distribution_ary_es,
    introduced_uncertain_distribution_ary_es,
    reintroduced_distribution_ary_es,
    extinct_distribution_ary_es,
    extinct_uncertain_distribution_ary_es,
    uncertain_distribution_ary_es,
    all_distribution_ary_fr,
    native_distribution_ary_fr,
    introduced_distribution_ary_fr,
    introduced_uncertain_distribution_ary_fr,
    reintroduced_distribution_ary_fr,
    extinct_distribution_ary_fr,
    extinct_uncertain_distribution_ary_fr,
    uncertain_distribution_ary_fr,
    CASE
      WHEN
        name_status = 'A'
        AND (
          ranks.name = 'SPECIES'
          OR (
            ranks.name = 'SUBSPECIES'
            AND (
              taxonomies.name = 'CITES_EU'
              AND (
                (listing->'cites_historically_listed')::BOOLEAN
                OR (listing->'eu_historically_listed')::BOOLEAN
              )
              OR
              taxonomies.name = 'CMS'
              AND (listing->'cms_historically_listed')::BOOLEAN
            )
          )
        )
      THEN TRUE
      ELSE FALSE
    END AS show_in_species_plus
    FROM taxon_concepts
    JOIN ranks ON ranks.id = rank_id
    JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
    LEFT JOIN (
      SELECT *
      FROM
      CROSSTAB(
      'SELECT taxon_commons.taxon_concept_id AS taxon_concept_id_com, languages.iso_code1 AS lng,
      ARRAY_AGG_NOTNULL(common_names.name ORDER BY common_names.name) AS common_names_ary
      FROM "taxon_commons"
      INNER JOIN "common_names"
      ON "common_names"."id" = "taxon_commons"."common_name_id"
      INNER JOIN "languages"
      ON "languages"."id" = "common_names"."language_id" AND UPPER(languages.iso_code1) IN (''EN'', ''FR'', ''ES'')
      GROUP BY taxon_commons.taxon_concept_id, languages.iso_code1
      ORDER BY 1,2',
      'SELECT DISTINCT languages.iso_code1 FROM languages WHERE UPPER(languages.iso_code1) IN (''EN'', ''FR'', ''ES'') order by 1'
      ) AS ct(
      taxon_concept_id_com INTEGER,
      english_names_ary VARCHAR[], spanish_names_ary VARCHAR[], french_names_ary VARCHAR[]
      )
    ) common_names ON taxon_concepts.id = common_names.taxon_concept_id_com
    LEFT JOIN (
      SELECT taxon_relationships.taxon_concept_id AS taxon_concept_id_syn,
      ARRAY_AGG_NOTNULL(synonym_tc.full_name) AS synonyms_ary,
      ARRAY_AGG_NOTNULL(synonym_tc.author_year) AS synonyms_author_years_ary
      FROM taxon_relationships
      JOIN "taxon_relationship_types"
      ON "taxon_relationship_types"."id" = "taxon_relationships"."taxon_relationship_type_id"
      AND "taxon_relationship_types"."name" = 'HAS_SYNONYM'
      JOIN taxon_concepts AS synonym_tc
      ON synonym_tc.id = taxon_relationships.other_taxon_concept_id
      GROUP BY taxon_relationships.taxon_concept_id
    ) synonyms ON taxon_concepts.id = synonyms.taxon_concept_id_syn
    LEFT JOIN (
      SELECT taxon_concept_id_sub, ARRAY_AGG(subspecies_ary) AS subspecies_not_listed_ary
      FROM
      (
      SELECT taxon_concepts.parent_id AS taxon_concept_id_sub,
      taxon_concepts.full_name AS subspecies_ary
      FROM taxon_concepts
      JOIN ranks ON ranks.id = taxon_concepts.rank_id
      AND ranks.name = 'VARIETY'
      WHERE name_status NOT IN ('S', 'T', 'N')
      GROUP BY taxon_concept_id_sub, taxon_concepts.full_name
      UNION
      (
      SELECT taxon_concepts.parent_id AS taxon_concept_id_sub,
      taxon_concepts.full_name AS subspecies_ary
      FROM taxon_concepts
      JOIN ranks ON ranks.id = taxon_concepts.rank_id
      AND ranks.name = 'SUBSPECIES'
      WHERE name_status NOT IN ('S', 'T', 'N')
      GROUP BY taxon_concept_id_sub, taxon_concepts.full_name
      EXCEPT
      SELECT taxon_concepts.parent_id AS taxon_concept_id_sub,
      taxon_concepts.full_name AS subspecies_ary
      FROM taxon_concepts
      JOIN ranks ON ranks.id = taxon_concepts.rank_id
      AND ranks.name = 'SUBSPECIES'
      JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
      WHERE name_status NOT IN ('S', 'T', 'N')
      AND CASE
        WHEN taxonomies.name = 'CMS'
        THEN (listing->'cms_historically_listed')::BOOLEAN
        ELSE (listing->'cites_historically_listed')::BOOLEAN
        OR (listing->'eu_historically_listed')::BOOLEAN
      END
      GROUP BY taxon_concept_id_sub, taxon_concepts.full_name
      )
      ) AS subquery
      GROUP by taxon_concept_id_sub
    ) subspecies ON taxon_concepts.id = subspecies.taxon_concept_id_sub
    LEFT JOIN (
      SELECT distributions.taxon_concept_id AS taxon_concept_id_cnt,
      ARRAY_AGG_NOTNULL(geo_entities.id ORDER BY geo_entities.name_en) AS countries_ids_ary,
      ARRAY_AGG_NOTNULL(geo_entities.iso_code2 ORDER BY geo_entities.name_en) AS all_distribution_iso_codes_ary,
      ARRAY_AGG_NOTNULL(geo_entities.name_en ORDER BY geo_entities.name_en) AS all_distribution_ary_en,
      ARRAY_AGG_NOTNULL(geo_entities.name_en ORDER BY geo_entities.name_es) AS all_distribution_ary_es,
      ARRAY_AGG_NOTNULL(geo_entities.name_en ORDER BY geo_entities.name_fr) AS all_distribution_ary_fr
      FROM distributions
      JOIN geo_entities
      ON distributions.geo_entity_id = geo_entities.id
      JOIN "geo_entity_types"
      ON "geo_entity_types"."id" = "geo_entities"."geo_entity_type_id"
      AND (geo_entity_types.name = 'COUNTRY' OR geo_entity_types.name = 'TERRITORY')
      GROUP BY distributions.taxon_concept_id
    ) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_cnt
    LEFT JOIN  (
      SELECT *
      FROM CROSSTAB(
        'SELECT distributions.taxon_concept_id,
          CASE WHEN tags.name IS NULL THEN ''NATIVE'' ELSE UPPER(tags.name) END || ''_'' || lng AS tag,
          ARRAY_AGG_NOTNULL(geo_entities.name ORDER BY geo_entities.name) AS locations_ary
        FROM distributions
        JOIN (
          SELECT geo_entities.id, geo_entities.iso_code2,  ''EN'' AS lng, geo_entities.name_en AS name FROM geo_entities
          UNION
          SELECT geo_entities.id, geo_entities.iso_code2, ''ES'' AS lng, geo_entities.name_es AS name FROM geo_entities
          UNION
          SELECT geo_entities.id, geo_entities.iso_code2, ''FR'' AS lng, geo_entities.name_fr AS name FROM geo_entities
        ) geo_entities
          ON geo_entities.id = distributions.geo_entity_id
        LEFT JOIN taggings
          ON taggable_id = distributions.id AND taggable_type = ''Distribution''
        LEFT JOIN tags
          ON tags.id = taggings.tag_id
          AND (
            UPPER(tags.name) IN (
              ''INTRODUCED'', ''INTRODUCED (?)'', ''REINTRODUCED'',
              ''EXTINCT'', ''EXTINCT (?)'', ''DISTRIBUTION UNCERTAIN''
            ) OR tags.name IS NULL
          )
        GROUP BY distributions.taxon_concept_id, tags.name, geo_entities.lng
        ',
        'SELECT * FROM UNNEST(
          ARRAY[
            ''NATIVE_EN'', ''INTRODUCED_EN'', ''INTRODUCED (?)_EN'', ''REINTRODUCED_EN'',
            ''EXTINCT_EN'', ''EXTINCT (?)_EN'', ''DISTRIBUTION UNCERTAIN_EN'',
            ''NATIVE_ES'', ''INTRODUCED_ES'', ''INTRODUCED (?)_ES'', ''REINTRODUCED_ES'',
            ''EXTINCT_ES'', ''EXTINCT (?)_ES'', ''DISTRIBUTION UNCERTAIN_ES'',
            ''NATIVE_FR'', ''INTRODUCED_FR'', ''INTRODUCED (?)_FR'', ''REINTRODUCED_FR'',
            ''EXTINCT_FR'', ''EXTINCT (?)_FR'', ''DISTRIBUTION UNCERTAIN_FR''
          ])'
      ) AS ct(
        taxon_concept_id INTEGER,
        native_distribution_ary_en VARCHAR[],
        introduced_distribution_ary_en VARCHAR[],
        introduced_uncertain_distribution_ary_en VARCHAR[],
        reintroduced_distribution_ary_en VARCHAR[],
        extinct_distribution_ary_en VARCHAR[],
        extinct_uncertain_distribution_ary_en VARCHAR[],
        uncertain_distribution_ary_en VARCHAR[],
        native_distribution_ary_es VARCHAR[],
        introduced_distribution_ary_es VARCHAR[],
        introduced_uncertain_distribution_ary_es VARCHAR[],
        reintroduced_distribution_ary_es VARCHAR[],
        extinct_distribution_ary_es VARCHAR[],
        extinct_uncertain_distribution_ary_es VARCHAR[],
        uncertain_distribution_ary_es VARCHAR[],
        native_distribution_ary_fr VARCHAR[],
        introduced_distribution_ary_fr VARCHAR[],
        introduced_uncertain_distribution_ary_fr VARCHAR[],
        reintroduced_distribution_ary_fr VARCHAR[],
        extinct_distribution_ary_fr VARCHAR[],
        extinct_uncertain_distribution_ary_fr VARCHAR[],
        uncertain_distribution_ary_fr VARCHAR[]
      )
    ) distributions_by_tag ON taxon_concepts.id = distributions_by_tag.taxon_concept_id;

    RAISE INFO 'Creating taxon concepts materialized view (tmp)';
    CREATE TABLE taxon_concepts_mview_tmp AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM taxon_concepts_view_tmp;

    RAISE INFO 'Creating indexes on taxon concepts materialized view (tmp)';
    CREATE INDEX ON taxon_concepts_mview_tmp (id);
    CREATE INDEX ON taxon_concepts_mview_tmp (parent_id);
    CREATE INDEX ON taxon_concepts_mview_tmp (taxonomy_is_cites_eu, cites_listed, kingdom_position);
    CREATE INDEX ON taxon_concepts_mview_tmp (cms_show, name_status, cms_listing_original, taxonomy_is_cites_eu, rank_name); -- cms csv download
    CREATE INDEX ON taxon_concepts_mview_tmp (cites_show, name_status, cites_listing_original, taxonomy_is_cites_eu, rank_name); -- cites csv download
    CREATE INDEX ON taxon_concepts_mview_tmp (eu_show, name_status, eu_listing_original, taxonomy_is_cites_eu, rank_name); -- eu csv download
    CREATE INDEX ON taxon_concepts_mview_tmp USING GIN (countries_ids_ary);

    RAISE INFO 'Swapping taxon concepts materialized view';
    DROP table IF EXISTS taxon_concepts_mview CASCADE;
    ALTER TABLE taxon_concepts_mview_tmp RENAME TO taxon_concepts_mview;
    DROP view IF EXISTS taxon_concepts_view CASCADE;
    ALTER TABLE taxon_concepts_view_tmp RENAME TO taxon_concepts_view;

    DROP table IF EXISTS auto_complete_taxon_concepts_mview_tmp CASCADE;
    RAISE INFO 'Creating auto complete taxon concepts materialized view (tmp)';
    CREATE TABLE auto_complete_taxon_concepts_mview_tmp AS
    WITH match_lookup (name_for_matching, matched_id, matched_name, id, full_name) AS (
      SELECT
        UPPER(full_name),
        id,
        NULL,
        id,
        full_name
      FROM taxon_concepts

      UNION

      SELECT
        UPPER(tc.full_name),
        tc.id,
        tc.full_name,
        atc.id,
        atc.full_name
      FROM taxon_concepts tc
      JOIN taxon_relationships tr
      ON tr.other_taxon_concept_id = tc.id
      JOIN taxon_relationship_types trt
      ON trt.id = tr.taxon_relationship_type_id
      AND trt.name = 'HAS_SYNONYM'
      JOIN taxon_concepts atc
      ON atc.id = tr.taxon_concept_id
      WHERE tc.name_status = 'S' AND atc.name_status = 'A' -- just in case

      UNION

      SELECT
        UPPER(UNNEST(REGEXP_SPLIT_TO_ARRAY(common_names.name, ' '))),
        NULL,
        common_names.name,
        tc.id,
        tc.full_name
      FROM taxon_concepts tc
      JOIN taxon_commons
      ON tc.id = taxon_commons.taxon_concept_id
      JOIN common_names
      ON common_names.id = taxon_commons.common_name_id
      JOIN languages
      ON languages.id = common_names.language_id
      AND languages.iso_code1 IN ('EN', 'ES', 'FR')
      WHERE tc.name_status = 'A' -- just in case
    ), taxa_with_visibility_flags AS (
      SELECT taxon_concepts.id,
        CASE
        WHEN taxonomies.name = 'CITES_EU' THEN TRUE
        ELSE FALSE
        END AS taxonomy_is_cites_eu,
        name_status,
        ranks.name AS rank_name,
        ranks.display_name_en AS rank_display_name_en,
        ranks.display_name_es AS rank_display_name_es,
        ranks.display_name_fr AS rank_display_name_fr,
        ranks.taxonomic_position AS rank_order,
        taxon_concepts.taxonomic_position,
        CASE
          WHEN
            name_status = 'A'
            AND (
              ranks.name != 'SUBSPECIES'
              AND ranks.name != 'VARIETY'
              OR taxonomies.name = 'CITES_EU'
              AND (
                (listing->'cites_historically_listed')::BOOLEAN
                OR (listing->'eu_historically_listed')::BOOLEAN
              )
              OR taxonomies.name = 'CMS'
              AND (listing->'cms_historically_listed')::BOOLEAN
            )
          THEN TRUE
          ELSE FALSE
        END AS show_in_species_plus_ac,
        CASE
          WHEN
            name_status = 'A'
            AND (
              ranks.name != 'SUBSPECIES'
              AND ranks.name != 'VARIETY'
              OR (listing->'cites_show')::BOOLEAN
            )
          THEN TRUE
          ELSE FALSE
        END AS show_in_checklist_ac,
        CASE
          WHEN
            taxonomies.name = 'CITES_EU'
            AND ARRAY['A', 'H', 'N']::VARCHAR[] && ARRAY[name_status]
          THEN TRUE
          ELSE FALSE
        END AS show_in_trade_ac,
        CASE
          WHEN
            taxonomies.name = 'CITES_EU'
            AND ARRAY['A', 'H', 'N', 'T']::VARCHAR[] && ARRAY[name_status]
          THEN TRUE
          ELSE FALSE
        END AS show_in_trade_internal_ac
        FROM taxon_concepts
        JOIN ranks ON ranks.id = rank_id
        JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
    )
    SELECT t1.*, name_for_matching, matched_id, matched_name, full_name FROM taxa_with_visibility_flags t1
    JOIN match_lookup t2
    ON t1.id = t2.id
    WHERE LENGTH(t2.name_for_matching) >= 3;

    RAISE INFO 'Creating indexes on auto complete taxon concepts materialized view (tmp)';

    --this one used for Species+ autocomplete (both main and higher taxa in downloads)
    CREATE INDEX ON auto_complete_taxon_concepts_mview_tmp
    USING BTREE(name_for_matching text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_species_plus_ac);
    --this one used for Checklist autocomplete
    CREATE INDEX ON auto_complete_taxon_concepts_mview_tmp
    USING BTREE(name_for_matching text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_checklist_ac);
    --this one used for Trade autocomplete
    CREATE INDEX ON auto_complete_taxon_concepts_mview_tmp
    USING BTREE(name_for_matching text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_trade_ac);
    --this one used for Trade internal autocomplete
    CREATE INDEX ON auto_complete_taxon_concepts_mview_tmp
    USING BTREE(name_for_matching text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_trade_internal_ac);

    RAISE INFO 'Swapping auto complete taxon concepts materialized view';
    DROP table IF EXISTS auto_complete_taxon_concepts_mview CASCADE;
    ALTER TABLE auto_complete_taxon_concepts_mview_tmp RENAME TO auto_complete_taxon_concepts_mview;

  END;
  $$;


--
-- Name: FUNCTION rebuild_taxon_concepts_mview(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_taxon_concepts_mview() IS 'Procedure to rebuild taxon concepts materialized view in the database.';


--
-- Name: rebuild_taxonomic_positions_for_animalia_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomic_positions_for_animalia_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- update taxonomic position
    WITH RECURSIVE self_and_descendants AS (
      SELECT h.id, COALESCE(h.taxonomic_position, '') AS ancestors_taxonomic_position
      FROM taxon_concepts h
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = node_id

      UNION

      SELECT hi.id,
      CASE
        WHEN (ranks.fixed_order) THEN hi.taxonomic_position
        -- use generous zero padding to accommodate for orchidacea (30 thousand species in about 900 genera)
        ELSE (self_and_descendants.ancestors_taxonomic_position || '.' || LPAD(
          (ROW_NUMBER() OVER (PARTITION BY parent_id ORDER BY full_name)::VARCHAR(64)),
          5,
          '0'
        ))::VARCHAR(255)
      END
      FROM self_and_descendants
      JOIN taxon_concepts hi ON hi.parent_id = self_and_descendants.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET
    taxonomic_position = ancestors_taxonomic_position
    FROM self_and_descendants
    WHERE taxon_concepts.id = self_and_descendants.id;

  END;
  $$;


--
-- Name: rebuild_taxonomic_positions_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomic_positions_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    ancestor_kingdom_name text;
    kingdom_node_id integer;
    ancestor_node_id integer;
    ancestor_rank_name text;
  BEGIN
    IF node_id IS NOT NULL THEN
      -- find kingdom for this node
      -- find the closest ancestor with taxonomic position set
      WITH RECURSIVE self_and_ancestors AS (
          SELECT h.id, h.parent_id, h.taxonomic_position, 1 AS level,
            h.data->'kingdom_name' AS kingdom_name,
            h.data->'rank_name' AS rank_name
          FROM taxon_concepts h
          WHERE id = node_id

          UNION

          SELECT hi.id, hi.parent_id, hi.taxonomic_position, level + 1,
            hi.data->'kingdom_name', hi.data->'rank_name'
          FROM taxon_concepts hi
          JOIN self_and_ancestors ON self_and_ancestors.parent_id = hi.id
      )
      SELECT id, rank_name, kingdom_name INTO ancestor_node_id, ancestor_rank_name, ancestor_kingdom_name
      FROM self_and_ancestors
      WHERE taxonomic_position IS NOT NULL AND id != node_id
      ORDER BY level
      LIMIT 1;
      -- and rebuild animalia or plantae subtree
      IF ancestor_kingdom_name = 'Animalia' THEN
        PERFORM rebuild_taxonomic_positions_for_animalia_node(ancestor_node_id);
      ELSE
        PERFORM rebuild_taxonomic_positions_for_plantae_node(ancestor_node_id, ancestor_rank_name);
      END IF;
    ELSE
      -- rebuild animalia and plantae trees separately
      -- CITES Animalia
      SELECT taxon_concepts.id INTO kingdom_node_id
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id
      AND taxonomies.name = 'CITES_EU'
      WHERE full_name = 'Animalia';
      PERFORM rebuild_taxonomic_positions_for_animalia_node(kingdom_node_id);
      -- CMS Animalia
      SELECT taxon_concepts.id INTO kingdom_node_id
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id
      AND taxonomies.name = 'CMS'
      WHERE full_name = 'Animalia';
      PERFORM rebuild_taxonomic_positions_for_animalia_node(kingdom_node_id);
      -- CITES Plantae
      SELECT taxon_concepts.id INTO kingdom_node_id
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id
      AND taxonomies.name = 'CITES_EU'
      WHERE full_name = 'Plantae';
      PERFORM rebuild_taxonomic_positions_for_plantae_node(kingdom_node_id, 'KINGDOM');
    END IF;

  END;
  $$;


--
-- Name: rebuild_taxonomic_positions_for_plantae_node(integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomic_positions_for_plantae_node(node_id integer, rank_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$

  BEGIN
    IF rank_name IN ('KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY')  THEN
      -- rebuild higher taxonomic ranks
      WITH plantae_root AS (
        SELECT taxon_concepts.id, taxonomic_position
        FROM taxon_concepts
        JOIN taxonomies
        ON taxonomies.id = taxon_concepts.taxonomy_id
        AND taxonomies.name = 'CITES_EU'
        WHERE full_name = 'Plantae'
      ), missing_higher_taxa AS (
        UPDATE taxon_concepts
        SET taxonomic_position = plantae_root.taxonomic_position
        FROM plantae_root
        WHERE plantae_root.id = (taxon_concepts.data->'kingdom_id')::INT
        AND data->'rank_name' IN ('PHYLUM', 'CLASS', 'ORDER')
      ), families AS (
        SELECT taxon_concepts.id, plantae_root.taxonomic_position || '.' || LPAD(
          (
            ROW_NUMBER()
            OVER (PARTITION BY rank_id ORDER BY full_name)::VARCHAR(64)
          )::VARCHAR(64),
          5,
          '0'
        ) AS taxonomic_position
        FROM taxon_concepts
        JOIN plantae_root ON plantae_root.id = (taxon_concepts.data->'kingdom_id')::INT
        WHERE data->'rank_name' = 'FAMILY'
      )
      UPDATE taxon_concepts
      SET taxonomic_position = families.taxonomic_position
      FROM families
      WHERE families.id = taxon_concepts.id;
    END IF;

    -- update taxonomic position
    WITH RECURSIVE self_and_descendants AS (
      SELECT h.id,
        COALESCE(h.taxonomic_position, '') AS ancestors_taxonomic_position
      FROM taxon_concepts h
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = node_id

      UNION

      SELECT hi.id,
      CASE
        WHEN hi.data->'rank_name' IN ('PHYLUM', 'CLASS', 'ORDER', 'FAMILY')
        THEN hi.taxonomic_position
        -- use generous zero padding to accommodate for orchidacea (30 thousand species in about 900 genera)
        ELSE (self_and_descendants.ancestors_taxonomic_position || '.' || LPAD(
          (ROW_NUMBER() OVER (PARTITION BY parent_id ORDER BY full_name)::VARCHAR(64)),
          5,
          '0'
        ))::VARCHAR(255)
      END
      FROM self_and_descendants
      JOIN taxon_concepts hi ON hi.parent_id = self_and_descendants.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET
    taxonomic_position = ancestors_taxonomic_position
    FROM self_and_descendants
    WHERE taxon_concepts.id = self_and_descendants.id
    AND taxon_concepts.data->'rank_name' NOT IN ('PHYLUM', 'CLASS', 'ORDER', 'FAMILY');

  END;
  $$;


--
-- Name: rebuild_taxonomy(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomy() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    PERFORM rebuild_taxonomy_for_node(NULL);
  END;
  $$;


--
-- Name: FUNCTION rebuild_taxonomy(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_taxonomy() IS '
Procedure to rebuild the computed full name, rank and ancestor names fields
 in taxon_concepts.';


--
-- Name: rebuild_taxonomy_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomy_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- update rank name
    UPDATE taxon_concepts
    SET data = COALESCE(taxon_concepts.data, ''::HSTORE) || HSTORE('rank_name', ranks.name)
    FROM taxon_concepts q
    JOIN ranks ON q.rank_id = ranks.id
    WHERE taxon_concepts.id = q.id
      AND CASE
        WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id
        ELSE TRUE
      END;

    -- update full name
    WITH RECURSIVE q AS (
      SELECT h.id, ranks.name AS rank_name, ancestors_names(h.id) AS ancestors_names
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE name_status = 'A' AND
        CASE
        WHEN node_id IS NOT NULL THEN h.id = node_id
        ELSE h.parent_id IS NULL
        END

      UNION

      SELECT hi.id, ranks.name,
      ancestors_names ||
      hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
      hstore(LOWER(ranks.name) || '_id', (hi.id)::VARCHAR)
      FROM q
      JOIN taxon_concepts hi
      ON hi.parent_id = q.id AND hi.name_status = 'A'
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET
    full_name = full_name(rank_name, ancestors_names),
    data = COALESCE(data, ''::HSTORE) || ancestors_names
    FROM q
    WHERE taxon_concepts.id = q.id;

    -- do not recalculate position for individual node
    -- as it takes too long to run on insert trigger
    IF node_id IS NULL THEN
      PERFORM rebuild_taxonomic_positions_for_node(node_id);
    END IF;

  END;
  $$;


--
-- Name: rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomies); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy taxonomies) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    tc_table_name TEXT;
    sql TEXT;
  BEGIN
    SELECT LOWER(taxonomy.name) || '_taxon_concepts_and_ancestors_mview' INTO tc_table_name;

    EXECUTE 'DROP TABLE IF EXISTS ' || tc_table_name || ' CASCADE';

    -- This query took like half a day to get right, so maybe it deserves a comment.
    -- It uses a sql procedure (ary_higher_or_equal_ranks_names) to return all ranks above
    -- the current taxon concept and then from those ranks get at actual ancestor ids.
    -- The reason for doing it that way is to make use of ancestor data which we already store
    -- for every taxon concept in columns named 'name_of_rank_id'.
    -- We also want to know the tree distance between the current taxon concept and any
    -- of its ancestors.
    -- So we call the higher_or_equal_ranks_names procedure for every taxon concept,
    -- and the only way to parametrise it correctly is to call it in the select clause.
    -- Because it returns an array of ranks, and what we want is a set of (taxon concept, ancestor, distance),
    -- we then go through the UNNEST thing in order to arrive at separate rows per ancestor.
    -- In order to know the distance it is enough to know the index of the ancestor in the originally
    -- returned array, because it is already sorted accordingly. That's what GENERATE_SUBSCRIPTS does.
    -- Quite surprisingly, this worked.

    sql := 'CREATE TEMP TABLE ' || tc_table_name || ' AS
    SELECT id AS taxon_concept_id,
    (
      data->(LOWER(UNNEST(higher_or_equal_ranks_names(data->''rank_name''))) || ''_id'')
    )::INT AS ancestor_taxon_concept_id,
    GENERATE_SUBSCRIPTS(higher_or_equal_ranks_names(data->''rank_name''), 1) - 1 AS tree_distance
    FROM taxon_concepts
    WHERE taxonomy_id = ' || taxonomy.id;

    EXECUTE sql;

    EXECUTE 'CREATE INDEX ON ' || tc_table_name || ' (ancestor_taxon_concept_id)';
    
    PERFORM rebuild_taxonomy_tmp_taxon_concepts_mview(taxonomy);
  END
  $$;


--
-- Name: FUNCTION rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy taxonomies); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy taxonomies) IS 'Procedure to create a helper table with all taxon - ancestor pairs in a given taxonomy.';


--
-- Name: rebuild_taxonomy_tmp_taxon_concepts_mview(taxonomies); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomy_tmp_taxon_concepts_mview(taxonomy taxonomies) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $_$
  DECLARE
    tc_table_name TEXT;
    sql TEXT;
  BEGIN
    SELECT LOWER(taxonomy.name) || '_tmp_taxon_concepts_mview' INTO tc_table_name;

    EXECUTE 'DROP TABLE IF EXISTS ' || tc_table_name || ' CASCADE';

    sql := 'CREATE TEMP TABLE ' || tc_table_name || ' AS
    SELECT taxon_concepts.id,
    (data->''kingdom_id'')::INTEGER AS kingdom_id,
    (data->''phylum_id'')::INTEGER AS phylum_id,
    (data->''class_id'')::INTEGER AS class_id,
    (data->''order_id'')::INTEGER AS order_id,
    (data->''family_id'')::INTEGER AS family_id,
    (data->''subfamily_id'')::INTEGER AS subfamily_id,
    (data->''genus_id'')::INTEGER AS genus_id,
    (data->''species_id'')::INTEGER AS species_id,
    (data->''subspecies_id'')::INTEGER AS subspecies_id,
    countries_ids_ary
    FROM taxon_concepts
    LEFT JOIN taxonomies
    ON taxonomies.id = taxon_concepts.taxonomy_id
    LEFT JOIN (
      SELECT taxon_concepts.id AS taxon_concept_id_cnt,
      ARRAY(
        SELECT *
        FROM UNNEST(ARRAY_AGG(geo_entities.id ORDER BY geo_entities.name_en)) s
        WHERE s IS NOT NULL
      ) AS countries_ids_ary
      FROM taxon_concepts
      LEFT JOIN distributions
      ON "distributions"."taxon_concept_id" = "taxon_concepts"."id"
      LEFT JOIN geo_entities
      ON distributions.geo_entity_id = geo_entities.id
      GROUP BY taxon_concepts.id
    ) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_cnt
    WHERE taxonomy_id=$1';

    EXECUTE sql USING taxonomy.id;

    EXECUTE 'CREATE UNIQUE INDEX ON ' || tc_table_name || ' (id)';
  END
  $_$;


--
-- Name: FUNCTION rebuild_taxonomy_tmp_taxon_concepts_mview(taxonomy taxonomies); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_taxonomy_tmp_taxon_concepts_mview(taxonomy taxonomies) IS 'Procedure to create a helper table with all taxon ancestors and aggregated distributions in a given taxonomy.';


--
-- Name: rebuild_touch_cites_taxon_concepts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_touch_cites_taxon_concepts() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    PERFORM rebuild_touch_designation_taxon_concepts('CITES');
  END;
  $$;


--
-- Name: rebuild_touch_cms_taxon_concepts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_touch_cms_taxon_concepts() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    PERFORM rebuild_touch_designation_taxon_concepts('CMS');
  END;
  $$;


--
-- Name: rebuild_touch_designation_taxon_concepts(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_touch_designation_taxon_concepts(designation_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    sql TEXT;
  BEGIN
    sql := 'WITH max_timestamp AS (
      SELECT lc.taxon_concept_id, GREATEST(tc.updated_at, MAX(lc.updated_at), tc.dependents_updated_at) AS updated_at
      FROM ' || designation_name || '_listing_changes_mview lc
      JOIN taxon_concepts_mview tc
      ON lc.taxon_concept_id = tc.id
      GROUP BY taxon_concept_id, tc.updated_at, tc.dependents_updated_at
    )
    UPDATE taxon_concepts
    SET touched_at = max_timestamp.updated_at
    FROM max_timestamp
    WHERE max_timestamp.taxon_concept_id = taxon_concepts.id
    AND (
      taxon_concepts.touched_at < max_timestamp.updated_at
      OR taxon_concepts.touched_at IS NULL
    );';
    EXECUTE sql;
  END;
  $$;


--
-- Name: rebuild_touch_eu_taxon_concepts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_touch_eu_taxon_concepts() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    PERFORM rebuild_touch_designation_taxon_concepts('EU');
  END;
  $$;


--
-- Name: rebuild_touch_taxon_concepts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_touch_taxon_concepts() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    WITH max_timestamp AS (
      SELECT lc.taxon_concept_id, GREATEST(tc.updated_at, MAX(lc.updated_at)) AS updated_at
      FROM listing_changes_mview lc
      JOIN taxon_concepts_mview tc
      ON lc.taxon_concept_id = tc.id
      GROUP BY taxon_concept_id, tc.updated_at
    )
    UPDATE taxon_concepts
    SET touched_at = max_timestamp.updated_at
    FROM max_timestamp
    WHERE max_timestamp.taxon_concept_id = taxon_concepts.id
    AND (
      taxon_concepts.touched_at < max_timestamp.updated_at
      OR taxon_concepts.touched_at IS NULL
    );
  END;
  $$;


--
-- Name: rebuild_valid_hybrid_appdx_year_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_valid_hybrid_appdx_year_mview() RETURNS void
    LANGUAGE sql
    AS $$
  WITH hybrids AS (
    SELECT other_taxon_concept_id AS hybrid_id,
    taxon_concept_id
    FROM taxon_relationships rel
    JOIN taxon_relationship_types rel_type
    ON rel.taxon_relationship_type_id = rel_type.id AND rel_type.name = 'HAS_HYBRID'
  )
  INSERT INTO valid_taxon_concept_appendix_year_mview (
    taxon_concept_id, appendix, effective_from, effective_to
  )
  SELECT hybrids.hybrid_id, appendix, effective_from, effective_to
  FROM valid_taxon_concept_appendix_year_mview intervals
  JOIN hybrids
  ON hybrids.taxon_concept_id = intervals.taxon_concept_id;
$$;


--
-- Name: rebuild_valid_taxon_concept_annex_year_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_valid_taxon_concept_annex_year_mview() RETURNS void
    LANGUAGE sql
    AS $$
    SELECT * FROM rebuild_valid_taxon_concept_appendix_year_designation_mview('EU');
    SELECT * FROM rebuild_ancestor_valid_tc_appdx_year_designation_mview('EU');
$$;


--
-- Name: rebuild_valid_taxon_concept_appendix_year_designation_mview(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_valid_taxon_concept_appendix_year_designation_mview(designation_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    mview_name TEXT;
    appendix TEXT;
  BEGIN
    IF designation_name = 'EU' THEN
      appendix := 'annex';
    ELSE
      appendix := 'appendix';
    END IF;
    mview_name := 'valid_taxon_concept_' || appendix || '_year_mview';

    EXECUTE 'DROP TABLE IF EXISTS ' || designation_name || '_listing_changes_intervals_mview;';

    EXECUTE 'CREATE TEMP TABLE ' || designation_name || '_listing_changes_intervals_mview AS
    WITH additions_and_deletions AS (
      SELECT change_type_name, effective_at, taxon_concept_id,
      species_listing_name, species_listing_id, party_id
      FROM ' || designation_name || '_listing_changes_mview
      WHERE change_type_name = ''ADDITION'' OR change_type_name = ''DELETION''
    ), additions AS (
      SELECT change_type_name, effective_at, taxon_concept_id,
      species_listing_name, species_listing_id, party_id
      FROM additions_and_deletions
      WHERE change_type_name = ''ADDITION''
    )
    SELECT a.taxon_concept_id, a.species_listing_name,
    a.effective_at AS effective_from,
    MIN(ad.effective_at) AS effective_to
    FROM additions a
    LEFT JOIN additions_and_deletions ad
    ON a.taxon_concept_id = ad.taxon_concept_id
    AND a.species_listing_id = ad.species_listing_id
    AND (a.party_id = ad.party_id OR ad.party_id IS NULL)
    AND a.effective_at < ad.effective_at
    GROUP BY a.taxon_concept_id, a.species_listing_name, a.effective_at';

    -- drop indexes on the mview
    IF designation_name = 'CITES' THEN
      EXECUTE 'DROP INDEX IF EXISTS ' || mview_name || '_year_idx';
    END IF;
    EXECUTE 'DROP INDEX IF EXISTS ' || mview_name || '_idx';
    -- truncate the mview
    EXECUTE 'TRUNCATE ' || mview_name;

    -- the following interval-merging query adapted from Solution 2
    -- http://blog.developpez.com/sqlpro/p9821/langage-sql-norme/agregation_d_intervalles_en_sql_1

    EXECUTE '
    WITH unmerged_intervals AS (
      SELECT F.effective_from, L.effective_to, F.taxon_concept_id, F.species_listing_name
      FROM ' || designation_name || '_listing_changes_intervals_mview AS F
      JOIN ' || designation_name || '_listing_changes_intervals_mview AS L
      ON (F.effective_to <= L.effective_to OR L.effective_to IS NULL)
        AND F.taxon_concept_id = L.taxon_concept_id
        AND F.species_listing_name = L.species_listing_name
      JOIN ' || designation_name || '_listing_changes_intervals_mview AS E
      ON F.taxon_concept_id = E.taxon_concept_id
        AND F.species_listing_name = E.species_listing_name
      GROUP  BY F.effective_from, L.effective_to,  F.taxon_concept_id, F.species_listing_name
      HAVING COUNT(
        CASE
          WHEN (E.effective_from < F.effective_from AND (F.effective_from <= E.effective_to OR E.effective_to IS NULL))  
            OR (E.effective_from <= L.effective_to AND (L.effective_to < E.effective_to OR E.effective_to IS NULL)) 
          THEN 1
        END
      ) = 0
    )
    INSERT INTO ' || mview_name || '
    (taxon_concept_id, ' || appendix || ', effective_from, effective_to)
    SELECT taxon_concept_id, species_listing_name,
    effective_from, MIN(effective_to) AS effective_to
    FROM   unmerged_intervals
    GROUP  BY taxon_concept_id, species_listing_name, effective_from';

    IF designation_name = 'CITES' THEN
      EXECUTE 'CREATE INDEX ' || mview_name || '_year_idx ON ' || mview_name || '(
        taxon_concept_id,
        DATE_PART(''year'', effective_from), DATE_PART(''year'', effective_to), ' ||
        appendix || '
      );';
    END IF;
    EXECUTE 'CREATE INDEX ' || mview_name || '_idx ON ' || mview_name || '
    (taxon_concept_id, effective_from, effective_to, ' || appendix || ');';
  END;
$$;


--
-- Name: rebuild_valid_taxon_concept_appendix_year_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_valid_taxon_concept_appendix_year_mview() RETURNS void
    LANGUAGE sql
    AS $$
    SELECT * FROM rebuild_valid_taxon_concept_appendix_year_designation_mview('CITES');
    SELECT * FROM rebuild_ancestor_valid_tc_appdx_year_designation_mview('CITES');
    SELECT * FROM rebuild_valid_tc_appdx_N_year_mview();
    SELECT * FROM rebuild_valid_hybrid_appdx_year_mview();
$$;


--
-- Name: rebuild_valid_tc_appdx_n_year_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_valid_tc_appdx_n_year_mview() RETURNS void
    LANGUAGE sql
    AS $$

  WITH unmerged_eu_intervals AS (
    SELECT F.effective_from, L.effective_to, F.taxon_concept_id
    FROM valid_taxon_concept_annex_year_mview AS F
    JOIN valid_taxon_concept_annex_year_mview AS L
    ON (F.effective_to <= L.effective_to OR L.effective_to IS NULL)
      AND F.taxon_concept_id = L.taxon_concept_id
    JOIN valid_taxon_concept_annex_year_mview AS E
    ON F.taxon_concept_id = E.taxon_concept_id
    GROUP  BY F.effective_from, L.effective_to,  F.taxon_concept_id
    HAVING COUNT(
      CASE
        WHEN (E.effective_from < F.effective_from AND (F.effective_from <= E.effective_to OR E.effective_to IS NULL))
          OR (E.effective_from <= L.effective_to AND (L.effective_to < E.effective_to OR E.effective_to IS NULL))
        THEN 1
      END
    ) = 0
  ), eu_intervals AS (
    SELECT taxon_concept_id, effective_from, MIN(effective_to) AS effective_to
    FROM   unmerged_eu_intervals
    GROUP  BY taxon_concept_id, effective_from
  ), unmerged_cites_intervals AS (
    SELECT F.effective_from, L.effective_to, F.taxon_concept_id
    FROM valid_taxon_concept_appendix_year_mview AS F
    JOIN valid_taxon_concept_appendix_year_mview AS L
    ON (F.effective_to <= L.effective_to OR L.effective_to IS NULL)
      AND F.taxon_concept_id = L.taxon_concept_id
    JOIN valid_taxon_concept_appendix_year_mview AS E
    ON F.taxon_concept_id = E.taxon_concept_id
    GROUP  BY F.effective_from, L.effective_to,  F.taxon_concept_id
    HAVING COUNT(
      CASE
        WHEN (E.effective_from < F.effective_from AND (F.effective_from <= E.effective_to OR E.effective_to IS NULL))
          OR (E.effective_from <= L.effective_to AND (L.effective_to < E.effective_to OR E.effective_to IS NULL))
        THEN 1
      END
    ) = 0
  ), cites_intervals AS (
    SELECT taxon_concept_id, effective_from, MIN(effective_to) AS effective_to,
    daterange(effective_from::date, MIN(effective_to)::date, '[]'::text) AS listing_interval
    FROM   unmerged_cites_intervals
    GROUP  BY taxon_concept_id, effective_from
  ), cites_intervals_with_lag AS (
    SELECT taxon_concept_id, listing_interval AS current,
    LAG(listing_interval) OVER (PARTITION BY taxon_concept_id ORDER BY LOWER(listing_interval)) AS previous
    FROM cites_intervals
  ), cites_intervals_with_lead AS (
    SELECT taxon_concept_id, listing_interval AS current,
    LEAD(listing_interval) OVER (PARTITION BY taxon_concept_id ORDER BY LOWER(listing_interval)) AS next
    FROM cites_intervals
  ), cites_gaps (taxon_concept_id, gap_effective_from, gap_effective_to) AS (
    SELECT taxon_concept_id, UPPER(previous), LOWER(current) FROM cites_intervals_with_lag
    UNION
    SELECT taxon_concept_id, UPPER(current), LOWER(next) FROM cites_intervals_with_lead
    WHERE UPPER(current) IS NOT NULL
  )
  INSERT INTO valid_taxon_concept_appendix_year_mview (taxon_concept_id, appendix, effective_from, effective_to)
  SELECT
    cites_gaps.taxon_concept_id, 'N',
    GREATEST(COALESCE(gap_effective_from, effective_from), effective_from) effective_from,
    LEAST(COALESCE(gap_effective_to, effective_to), effective_to) AS effective_to
  FROM cites_gaps
  JOIN eu_intervals
  ON eu_intervals.taxon_concept_id = cites_gaps.taxon_concept_id
  AND (
    -- gap is right closed
    gap_effective_to IS NOT NULL
    AND effective_from < gap_effective_to
    OR
    -- gap is right open
    gap_effective_to IS NULL
    AND (effective_to IS NULL OR effective_to > gap_effective_from)
  )
  UNION

  SELECT eu_intervals.taxon_concept_id, 'N', eu_intervals.effective_from, eu_intervals.effective_to
  FROM eu_intervals
  LEFT JOIN cites_gaps
  ON eu_intervals.taxon_concept_id = cites_gaps.taxon_concept_id
  WHERE cites_gaps.taxon_concept_id IS NULL;

$$;


--
-- Name: refresh_trade_sandbox_views(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION refresh_trade_sandbox_views() RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    PERFORM drop_trade_sandbox_views();
    PERFORM create_trade_sandbox_views();
    RETURN;
  END;
  $$;


--
-- Name: FUNCTION refresh_trade_sandbox_views(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION refresh_trade_sandbox_views() IS '
Drops all trade_sandbox_n_view views and creates them again. Useful when the
view definition has changed and has to be applied to existing views.';


--
-- Name: resolve_taxa_in_sandbox(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION resolve_taxa_in_sandbox(table_name character varying, shipment_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
  cites_taxonomy_id INTEGER;
  sql TEXT;
  updated_rows INTEGER;
BEGIN
  SELECT id INTO cites_taxonomy_id FROM taxonomies WHERE name = 'CITES_EU';
  IF NOT FOUND THEN
    RAISE NOTICE '[%] Taxonomy not found.', table_name;
    RETURN -1;
  END IF;

  sql :=  'WITH resolved_reported_taxa AS (
      SELECT DISTINCT ON (1)
        sandbox_table.id AS sandbox_shipment_id,
        taxon_concepts.id AS taxon_concept_id,
        taxon_concepts.full_name AS full_name
      FROM ' || table_name || ' sandbox_table
      JOIN taxon_concepts
        ON UPPER(taxon_concepts.full_name) =
          regexp_replace(
            UPPER(squish(sandbox_table.taxon_name)),
            E'' SPP(\.)?$'',
            ''''
          )
        AND taxonomy_id = ' || cites_taxonomy_id ||
      CASE WHEN shipment_id IS NOT NULL
        THEN ' WHERE sandbox_table.id = ' || shipment_id
        ELSE ''
      END ||
      '
      ORDER BY 1, CASE
        WHEN taxon_concepts.name_status = ''A'' THEN 1
        WHEN taxon_concepts.name_status = ''H'' THEN 2
        ELSE 3
      END
    ), resolved_taxa AS (
      SELECT DISTINCT ON (1)
        sandbox_shipment_id,
        resolved_reported_taxa.taxon_concept_id,
        resolved_reported_taxa.full_name AS reported_full_name,
        matched_taxon_concepts.id AS matched_taxon_concept_id
      FROM resolved_reported_taxa
      LEFT JOIN taxon_relationship_types
        ON taxon_relationship_types.name IN (''HAS_SYNONYM'', ''HAS_TRADE_NAME'')
      LEFT JOIN taxon_relationships
        ON taxon_relationships.other_taxon_concept_id = resolved_reported_taxa.taxon_concept_id
        AND taxon_relationships.taxon_relationship_type_id = taxon_relationship_types.id
      LEFT JOIN taxon_concepts matched_taxon_concepts
        ON matched_taxon_concepts.id = taxon_relationships.taxon_concept_id
        AND taxonomy_id = ' || cites_taxonomy_id ||
      '
      ORDER BY 1, CASE
        WHEN matched_taxon_concepts.name_status = ''A'' THEN 1
        WHEN matched_taxon_concepts.name_status = ''H'' THEN 2
        ELSE 3
      END
    )
    UPDATE ' || table_name ||
    '
    SET reported_taxon_concept_id = resolved_taxa.taxon_concept_id,
    taxon_name = resolved_taxa.reported_full_name,
    taxon_concept_id = CASE
      WHEN resolved_taxa.matched_taxon_concept_id IS NULL
      THEN resolved_taxa.taxon_concept_id
      ELSE resolved_taxa.matched_taxon_concept_id
    END
    FROM resolved_taxa
    WHERE ' || table_name || '.id = resolved_taxa.sandbox_shipment_id';
    EXECUTE sql;

    GET DIAGNOSTICS updated_rows = ROW_COUNT;
    -- RAISE INFO '[%] Updated % sandbox shipments', table_name, updated_rows;

    RETURN updated_rows;
END;
$_$;


--
-- Name: sanitize_taxon_name(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sanitize_taxon_name(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT regexp_replace(
      upper(substring(SQUISH_NULL($1) from 1 for 1)) ||
      lower(substring(SQUISH_NULL($1) from 2 for length(SQUISH_NULL($1)))),
      E' spp(\.)?$', '');
  $_$;


--
-- Name: FUNCTION sanitize_taxon_name(text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION sanitize_taxon_name(text) IS 'Converts the case, removes spp. and squish_nulls the species name';


--
-- Name: sapi_rebuild(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sapi_rebuild() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
          RAISE NOTICE 'Rebuilding SAPI database';
          PERFORM rebuild_taxonomy();
          PERFORM rebuild_cites_listing();
          PERFORM rebuild_eu_listing();
          PERFORM rebuild_cms_listing();
          PERFORM rebuild_cites_accepted_flags();
        END;
      $$;


--
-- Name: FUNCTION sapi_rebuild(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION sapi_rebuild() IS 'Procedure to rebuild computed fields in the database.';


--
-- Name: set_cites_eu_historically_listed_flag_for_node(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_cites_eu_historically_listed_flag_for_node(designation text, node_id integer) RETURNS void
    LANGUAGE sql
    AS $_$
    WITH historically_listed_taxa AS (
      SELECT taxon_concept_id AS id
      FROM listing_changes
      JOIN change_types
      ON change_types.id = change_type_id
      JOIN designations
      ON designations.id = designation_id AND designations.name = UPPER($1)
      WHERE CASE WHEN $2 IS NULL THEN TRUE ELSE taxon_concept_id = $2 END
      GROUP BY taxon_concept_id
    ), taxa_with_historically_listed_flag AS (
      SELECT taxon_concepts.id,
      CASE WHEN t.id IS NULL THEN FALSE ELSE TRUE END AS historically_listed
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id AND taxonomies.name = 'CITES_EU'
      LEFT JOIN historically_listed_taxa t
      ON t.id = taxon_concepts.id
      WHERE CASE WHEN $2 IS NULL THEN TRUE ELSE taxon_concepts.id = $2 END
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
    HSTORE(LOWER($1) || '_historically_listed', t.historically_listed::VARCHAR)
    FROM taxa_with_historically_listed_flag t
    WHERE t.id = taxon_concepts.id;
  $_$;


--
-- Name: set_cites_historically_listed_flag_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_cites_historically_listed_flag_for_node(node_id integer) RETURNS void
    LANGUAGE sql
    AS $_$
    SELECT * FROM set_cites_eu_historically_listed_flag_for_node('CITES', $1);
  $_$;


--
-- Name: set_cms_historically_listed_flag_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_cms_historically_listed_flag_for_node(node_id integer) RETURNS void
    LANGUAGE sql
    AS $_$
    WITH historical_listings_or_agreements AS (
      SELECT taxon_concept_id
      FROM listing_changes
      JOIN change_types
      ON change_types.id = change_type_id
      JOIN designations
      ON designations.id = designation_id AND designations.name = 'CMS'
      WHERE CASE WHEN $1 IS NULL THEN TRUE ELSE taxon_concept_id = $1 END

      UNION

      SELECT taxon_concept_id
      FROM taxon_instruments
      WHERE CASE WHEN $1 IS NULL THEN TRUE ELSE taxon_concept_id = $1 END
    ), historically_listed_taxa AS (
      SELECT taxon_concept_id AS id
      FROM historical_listings_or_agreements
      GROUP BY taxon_concept_id
    ), taxa_with_historically_listed_flag AS (
      SELECT taxon_concepts.id,
      CASE WHEN t.id IS NULL THEN FALSE ELSE TRUE END AS historically_listed
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id AND taxonomies.name = 'CMS'
      LEFT JOIN historically_listed_taxa t
      ON t.id = taxon_concepts.id
      WHERE CASE WHEN $1 IS NULL THEN TRUE ELSE taxon_concepts.id = $1 END
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) || HSTORE('cms_historically_listed', t.historically_listed::VARCHAR)
    FROM taxa_with_historically_listed_flag t
    WHERE t.id = taxon_concepts.id;
  $_$;


--
-- Name: set_eu_historically_listed_flag_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_eu_historically_listed_flag_for_node(node_id integer) RETURNS void
    LANGUAGE sql
    AS $_$
    SELECT * FROM set_cites_eu_historically_listed_flag_for_node('EU', $1);
  $_$;


--
-- Name: squish(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION squish(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT BTRIM(regexp_replace($1, E'\\s+', ' ', 'g'));
  $_$;


--
-- Name: FUNCTION squish(text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION squish(text) IS 'Squishes whitespace characters in a string';


--
-- Name: squish_null(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION squish_null(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE WHEN SQUISH($1) = '' THEN NULL ELSE SQUISH($1) END;
  $_$;


--
-- Name: FUNCTION squish_null(text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION squish_null(text) IS 'Squishes whitespace characters in a string and returns null for empty string';


--
-- Name: strip_tags(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION strip_tags(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT regexp_replace(regexp_replace($1, E'(?x)<[^>]*?(\s alt \s* = \s* ([\'"]) ([^>]*?) \2) [^>]*? >', E'\3'), E'(?x)(< [^>]*? >)', '', 'g')
  $_$;


--
-- Name: FUNCTION strip_tags(text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION strip_tags(text) IS 'Strips html tags from string using a regexp.';


--
-- Name: array_agg_notnull(anyelement); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE array_agg_notnull(anyelement) (
    SFUNC = fn_array_agg_notnull,
    STYPE = anyarray,
    INITCOND = '{}'
);


--
-- Name: ahoy_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ahoy_events (
    id uuid NOT NULL,
    visit_id uuid,
    user_id integer,
    name character varying(255),
    properties json,
    "time" timestamp without time zone
);


--
-- Name: ahoy_visits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ahoy_visits (
    id uuid NOT NULL,
    visitor_id uuid,
    ip character varying(255),
    user_agent text,
    referrer text,
    landing_page text,
    user_id integer,
    referring_domain character varying(255),
    search_keyword character varying(255),
    browser character varying(255),
    os character varying(255),
    device_type character varying(255),
    country character varying(255),
    city character varying(255),
    utm_source character varying(255),
    utm_medium character varying(255),
    utm_term character varying(255),
    utm_content character varying(255),
    utm_campaign character varying(255),
    started_at timestamp without time zone,
    organization text
);


--
-- Name: annotations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE annotations (
    id integer NOT NULL,
    symbol character varying(255),
    parent_symbol character varying(255),
    display_in_index boolean DEFAULT false NOT NULL,
    display_in_footnote boolean DEFAULT false NOT NULL,
    short_note_en text,
    full_note_en text,
    short_note_fr text,
    full_note_fr text,
    short_note_es text,
    full_note_es text,
    original_id integer,
    event_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    import_row_id integer,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE annotations_id_seq OWNED BY annotations.id;


--
-- Name: api_distributions_view; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_distributions_view (
    id integer,
    taxon_concept_id integer,
    name_en character varying(255),
    name_es character varying(255),
    name_fr character varying(255),
    iso_code2 character varying(255),
    geo_entity_type character varying(255),
    tags character varying[],
    citations text[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: api_taxon_concepts_view; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_taxon_concepts_view (
    id integer,
    parent_id integer,
    name character varying(255),
    taxonomy_is_cites_eu boolean,
    full_name character varying(255),
    author_year character varying(255),
    name_status text,
    rank character varying(255),
    taxonomic_position character varying,
    higher_taxa json,
    synonyms json,
    accepted_names json,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: auto_complete_taxon_concepts_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE auto_complete_taxon_concepts_mview (
    id integer,
    taxonomy_is_cites_eu boolean,
    name_status character varying(255),
    rank_name character varying(255),
    rank_display_name_en text,
    rank_display_name_es text,
    rank_display_name_fr text,
    rank_order character varying(255),
    taxonomic_position character varying(255),
    show_in_species_plus_ac boolean,
    show_in_checklist_ac boolean,
    show_in_trade_ac boolean,
    show_in_trade_internal_ac boolean,
    name_for_matching text,
    matched_id integer,
    matched_name character varying,
    full_name character varying(255)
);


--
-- Name: change_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE change_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    designation_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    display_name_en text NOT NULL,
    display_name_es text,
    display_name_fr text
);


--
-- Name: change_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE change_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE change_types_id_seq OWNED BY change_types.id;


--
-- Name: cites_listing_changes_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cites_listing_changes_mview (
    taxon_concept_id integer,
    id integer,
    original_taxon_concept_id integer,
    effective_at timestamp without time zone,
    species_listing_id integer,
    species_listing_name character varying(255),
    change_type_id integer,
    change_type_name character varying(255),
    designation_id integer,
    designation_name character varying(255),
    parent_id integer,
    party_id integer,
    party_iso_code character varying(255),
    party_full_name_en character varying(255),
    party_full_name_es character varying(255),
    party_full_name_fr character varying(255),
    ann_symbol character varying(255),
    full_note_en text,
    full_note_es text,
    full_note_fr text,
    short_note_en text,
    short_note_es text,
    short_note_fr text,
    display_in_index boolean,
    display_in_footnote boolean,
    hash_ann_symbol character varying(255),
    hash_ann_parent_symbol character varying(255),
    hash_full_note_en text,
    hash_full_note_es text,
    hash_full_note_fr text,
    inclusion_taxon_concept_id integer,
    inherited_short_note_en text,
    inherited_full_note_en text,
    inherited_short_note_es text,
    inherited_full_note_es text,
    inherited_short_note_fr text,
    inherited_full_note_fr text,
    auto_note_en text,
    auto_note_es text,
    auto_note_fr text,
    is_current boolean,
    explicit_change boolean,
    updated_at timestamp without time zone,
    show_in_history boolean,
    show_in_downloads boolean,
    show_in_timeline boolean,
    listed_geo_entities_ids integer[],
    excluded_geo_entities_ids integer[],
    excluded_taxon_concept_ids integer[],
    dirty boolean,
    expiry timestamp with time zone
);


--
-- Name: cites_species_listing_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cites_species_listing_mview (
    id integer,
    taxonomic_position character varying(255),
    kingdom_id integer,
    phylum_id integer,
    class_id integer,
    order_id integer,
    family_id integer,
    genus_id integer,
    kingdom_name text,
    phylum_name text,
    class_name text,
    order_name text,
    family_name text,
    genus_name text,
    species_name text,
    subspecies_name text,
    full_name character varying(255),
    author_year character varying(255),
    rank_name character varying(255),
    cites_listed boolean,
    cites_nc boolean,
    cites_listing_original text,
    original_taxon_concept_party_iso_code text,
    original_taxon_concept_full_name_with_spp text,
    original_taxon_concept_full_note_en text,
    original_taxon_concept_hash_full_note_en text,
    countries_ids_ary integer[],
    all_distribution text,
    all_distribution_iso_codes text,
    native_distribution text,
    introduced_distribution text,
    introduced_uncertain_distribution text,
    reintroduced_distribution text,
    extinct_distribution text,
    extinct_uncertain_distribution text,
    uncertain_distribution text
);


--
-- Name: cites_suspension_confirmations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cites_suspension_confirmations (
    id integer NOT NULL,
    cites_suspension_id integer NOT NULL,
    cites_suspension_notification_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cites_suspension_confirmations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cites_suspension_confirmations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cites_suspension_confirmations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cites_suspension_confirmations_id_seq OWNED BY cites_suspension_confirmations.id;


--
-- Name: cms_listing_changes_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cms_listing_changes_mview (
    taxon_concept_id integer,
    id integer,
    original_taxon_concept_id integer,
    effective_at timestamp without time zone,
    species_listing_id integer,
    species_listing_name character varying(255),
    change_type_id integer,
    change_type_name character varying(255),
    designation_id integer,
    designation_name character varying(255),
    parent_id integer,
    party_id integer,
    party_iso_code character varying(255),
    party_full_name_en character varying(255),
    party_full_name_es character varying(255),
    party_full_name_fr character varying(255),
    ann_symbol character varying(255),
    full_note_en text,
    full_note_es text,
    full_note_fr text,
    short_note_en text,
    short_note_es text,
    short_note_fr text,
    display_in_index boolean,
    display_in_footnote boolean,
    hash_ann_symbol character varying(255),
    hash_ann_parent_symbol character varying(255),
    hash_full_note_en text,
    hash_full_note_es text,
    hash_full_note_fr text,
    inclusion_taxon_concept_id integer,
    inherited_short_note_en text,
    inherited_full_note_en text,
    inherited_short_note_es text,
    inherited_full_note_es text,
    inherited_short_note_fr text,
    inherited_full_note_fr text,
    auto_note_en text,
    auto_note_es text,
    auto_note_fr text,
    is_current boolean,
    explicit_change boolean,
    updated_at timestamp without time zone,
    show_in_history boolean,
    show_in_downloads boolean,
    show_in_timeline boolean,
    listed_geo_entities_ids integer[],
    excluded_geo_entities_ids integer[],
    excluded_taxon_concept_ids integer[],
    dirty boolean,
    expiry timestamp with time zone
);


--
-- Name: cms_mappings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cms_mappings (
    id integer NOT NULL,
    taxon_concept_id integer,
    cms_uuid character varying(255),
    cms_taxon_name character varying(255),
    cms_author character varying(255),
    details hstore,
    accepted_name_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cms_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cms_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cms_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cms_mappings_id_seq OWNED BY cms_mappings.id;


--
-- Name: cms_species_listing_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cms_species_listing_mview (
    id integer,
    taxonomic_position character varying(255),
    kingdom_id integer,
    phylum_id integer,
    class_id integer,
    order_id integer,
    family_id integer,
    genus_id integer,
    phylum_name text,
    class_name text,
    order_name text,
    family_name text,
    genus_name text,
    full_name character varying(255),
    author_year character varying(255),
    rank_name character varying(255),
    agreement character varying,
    cms_listed boolean,
    cms_listing_original text,
    original_taxon_concept_full_name_with_spp text,
    original_taxon_concept_effective_at text,
    original_taxon_concept_full_note_en text,
    countries_ids_ary integer[],
    all_distribution text,
    all_distribution_iso_codes text,
    native_distribution text,
    introduced_distribution text,
    introduced_uncertain_distribution text,
    reintroduced_distribution text,
    extinct_distribution text,
    extinct_uncertain_distribution text,
    uncertain_distribution text
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    commentable_id integer,
    commentable_type character varying(255),
    comment_type character varying(255),
    note text,
    created_by_id integer,
    updated_by_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: common_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE common_names (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    language_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: common_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE common_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: common_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE common_names_id_seq OWNED BY common_names.id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE languages (
    id integer NOT NULL,
    name_en character varying(255) NOT NULL,
    name_fr character varying(255),
    name_es character varying(255),
    iso_code1 character varying(255),
    iso_code3 character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_commons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_commons (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    common_name_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    role character varying(255) DEFAULT 'default'::character varying,
    authentication_token character varying(255)
);


--
-- Name: common_names_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW common_names_view AS
 SELECT st.name_status,
    st.id,
    (st.data -> 'phylum_name'::text) AS accepted_phylum_name,
    (st.data -> 'class_name'::text) AS accepted_class_name,
    (st.data -> 'order_name'::text) AS accepted_order_name,
    (st.data -> 'family_name'::text) AS accepted_family_name,
    st.full_name,
    st.author_year,
    (st.data -> 'rank_name'::text) AS rank_name,
    st.taxonomic_position,
    n.name AS common_name,
    l.name_en AS common_name_language,
    taxonomies.name AS taxonomy_name,
    to_char(c.created_at, 'DD/MM/YYYY'::text) AS created_at,
    uc.name AS created_by,
    to_char(c.updated_at, 'DD/MM/YYYY'::text) AS updated_at,
    uu.name AS updated_by,
    taxonomies.id AS taxonomy_id
   FROM ((((((taxon_concepts st
     JOIN taxonomies ON ((taxonomies.id = st.taxonomy_id)))
     LEFT JOIN taxon_commons c ON ((c.taxon_concept_id = st.id)))
     LEFT JOIN common_names n ON ((c.common_name_id = n.id)))
     LEFT JOIN languages l ON ((n.language_id = l.id)))
     LEFT JOIN users uc ON ((c.created_by_id = uc.id)))
     LEFT JOIN users uu ON ((c.updated_by_id = uu.id)))
  WHERE ((st.name_status)::text = 'A'::text);


--
-- Name: designation_geo_entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE designation_geo_entities (
    id integer NOT NULL,
    designation_id integer NOT NULL,
    geo_entity_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: designation_geo_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE designation_geo_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: designation_geo_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE designation_geo_entities_id_seq OWNED BY designation_geo_entities.id;


--
-- Name: designations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE designations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: designations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE designations_id_seq OWNED BY designations.id;


--
-- Name: distribution_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE distribution_references (
    id integer NOT NULL,
    distribution_id integer NOT NULL,
    reference_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updated_by_id integer,
    created_by_id integer
);


--
-- Name: distribution_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE distribution_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: distribution_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE distribution_references_id_seq OWNED BY distribution_references.id;


--
-- Name: distributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE distributions (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    geo_entity_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    updated_by_id integer,
    internal_notes text
);


--
-- Name: distributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: distributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE distributions_id_seq OWNED BY distributions.id;


--
-- Name: document_citation_geo_entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE document_citation_geo_entities (
    id integer NOT NULL,
    document_citation_id integer,
    geo_entity_id integer,
    created_by_id integer,
    updated_by_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: document_citation_geo_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE document_citation_geo_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_citation_geo_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE document_citation_geo_entities_id_seq OWNED BY document_citation_geo_entities.id;


--
-- Name: document_citation_taxon_concepts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE document_citation_taxon_concepts (
    id integer NOT NULL,
    document_citation_id integer,
    taxon_concept_id integer,
    created_by_id integer,
    updated_by_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: document_citation_taxon_concepts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE document_citation_taxon_concepts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_citation_taxon_concepts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE document_citation_taxon_concepts_id_seq OWNED BY document_citation_taxon_concepts.id;


--
-- Name: document_citations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE document_citations (
    id integer NOT NULL,
    document_id integer,
    created_by_id integer,
    updated_by_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: document_citations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE document_citations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_citations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE document_citations_id_seq OWNED BY document_citations.id;


--
-- Name: document_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE document_tags (
    id integer NOT NULL,
    name character varying(255),
    type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: document_tags_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE document_tags_documents (
    document_id integer,
    document_tag_id integer
);


--
-- Name: document_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE document_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE document_tags_id_seq OWNED BY document_tags.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    title text NOT NULL,
    filename text NOT NULL,
    date date NOT NULL,
    type character varying(255) NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    event_id integer,
    language_id integer,
    legacy_id integer,
    created_by_id integer,
    updated_by_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    number character varying(255)
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: documents_view; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE documents_view (
    id integer,
    title text,
    filename text,
    date date,
    type character varying(255),
    is_public boolean,
    event_id integer,
    language_id integer,
    legacy_id integer,
    created_by_id integer,
    updated_by_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    number character varying(255),
    event_type character varying(255),
    taxon_concept_ids integer[],
    geo_entity_ids integer[],
    document_tags_ids integer[]
);


--
-- Name: downloads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    doc_type character varying(255),
    format character varying(255),
    status character varying(255) DEFAULT 'working'::character varying,
    path character varying(255),
    filename character varying(255),
    display_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: eu_decision_confirmations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eu_decision_confirmations (
    id integer NOT NULL,
    eu_decision_id integer,
    event_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: eu_decision_confirmations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eu_decision_confirmations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eu_decision_confirmations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE eu_decision_confirmations_id_seq OWNED BY eu_decision_confirmations.id;


--
-- Name: eu_decision_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eu_decision_types (
    id integer NOT NULL,
    name character varying(255),
    tooltip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    decision_type character varying(255)
);


--
-- Name: eu_decision_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eu_decision_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eu_decision_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE eu_decision_types_id_seq OWNED BY eu_decision_types.id;


--
-- Name: eu_decisions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eu_decisions (
    id integer NOT NULL,
    is_current boolean DEFAULT true,
    notes text,
    internal_notes text,
    taxon_concept_id integer,
    geo_entity_id integer,
    start_date timestamp without time zone,
    start_event_id integer,
    end_date timestamp without time zone,
    end_event_id integer,
    type character varying(255),
    conditions_apply boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    eu_decision_type_id integer,
    term_id integer,
    source_id integer,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: eu_decisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eu_decisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eu_decisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE eu_decisions_id_seq OWNED BY eu_decisions.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    name character varying(255),
    designation_id integer,
    description text,
    url text,
    is_current boolean DEFAULT false NOT NULL,
    type character varying(255) DEFAULT 'Event'::character varying NOT NULL,
    effective_at timestamp without time zone,
    published_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    legacy_id integer,
    end_date timestamp without time zone,
    subtype character varying(255),
    updated_by_id integer,
    created_by_id integer,
    extended_description text,
    multilingual_url text
);


--
-- Name: geo_entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_entities (
    id integer NOT NULL,
    geo_entity_type_id integer NOT NULL,
    name_en character varying(255) NOT NULL,
    name_fr character varying(255),
    name_es character varying(255),
    long_name character varying(255),
    iso_code2 character varying(255),
    iso_code3 character varying(255),
    legacy_id integer,
    legacy_type character varying(255),
    is_current boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trade_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_codes (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    name_es character varying(255),
    name_fr character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: eu_decisions_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW eu_decisions_view AS
 SELECT eu_decisions.taxon_concept_id,
    taxon_concepts.taxonomic_position,
    ((taxon_concepts.data -> 'kingdom_id'::text))::integer AS kingdom_id,
    ((taxon_concepts.data -> 'phylum_id'::text))::integer AS phylum_id,
    ((taxon_concepts.data -> 'class_id'::text))::integer AS class_id,
    ((taxon_concepts.data -> 'order_id'::text))::integer AS order_id,
    ((taxon_concepts.data -> 'family_id'::text))::integer AS family_id,
    (taxon_concepts.data -> 'kingdom_name'::text) AS kingdom_name,
    (taxon_concepts.data -> 'phylum_name'::text) AS phylum_name,
    (taxon_concepts.data -> 'class_name'::text) AS class_name,
    (taxon_concepts.data -> 'order_name'::text) AS order_name,
    (taxon_concepts.data -> 'family_name'::text) AS family_name,
    (taxon_concepts.data -> 'genus_name'::text) AS genus_name,
    lower((taxon_concepts.data -> 'species_name'::text)) AS species_name,
    lower((taxon_concepts.data -> 'subspecies_name'::text)) AS subspecies_name,
    taxon_concepts.full_name,
    (taxon_concepts.data -> 'rank_name'::text) AS rank_name,
    eu_decisions.start_date,
    to_char(eu_decisions.start_date, 'DD/MM/YYYY'::text) AS start_date_formatted,
    eu_decisions.geo_entity_id,
    geo_entities.name_en AS party,
        CASE
            WHEN ((eu_decision_types.name)::text ~* '^i+\)'::text) THEN (('(No opinion) '::text || (eu_decision_types.name)::text))::character varying
            ELSE eu_decision_types.name
        END AS decision_type_for_display,
    eu_decision_types.decision_type,
    sources.name_en AS source_name,
    terms.name_en AS term_name,
    eu_decisions.notes,
    start_event.name AS start_event_name,
        CASE
            WHEN ((((eu_decisions.type)::text = 'EuOpinion'::text) AND eu_decisions.is_current) OR (((((eu_decisions.type)::text = 'EuSuspension'::text) AND (start_event.effective_at < ('now'::text)::date)) AND (start_event.is_current = true)) AND ((eu_decisions.end_event_id IS NULL) OR (end_event.effective_at > ('now'::text)::date)))) THEN true
            ELSE false
        END AS is_valid,
        CASE
            WHEN ((((eu_decisions.type)::text = 'EuOpinion'::text) AND eu_decisions.is_current) OR (((((eu_decisions.type)::text = 'EuSuspension'::text) AND (start_event.effective_at < ('now'::text)::date)) AND (start_event.is_current = true)) AND ((eu_decisions.end_event_id IS NULL) OR (end_event.effective_at > ('now'::text)::date)))) THEN 'Valid'::text
            ELSE 'Not Valid'::text
        END AS is_valid_for_display,
        CASE
            WHEN ((eu_decisions.type)::text = 'EuOpinion'::text) THEN eu_decisions.start_date
            WHEN ((eu_decisions.type)::text = 'EuSuspension'::text) THEN start_event.effective_at
            ELSE NULL::timestamp without time zone
        END AS ordering_date
   FROM (((((((eu_decisions
     JOIN eu_decision_types ON ((eu_decision_types.id = eu_decisions.eu_decision_type_id)))
     JOIN taxon_concepts ON ((taxon_concepts.id = eu_decisions.taxon_concept_id)))
     LEFT JOIN events start_event ON ((start_event.id = eu_decisions.start_event_id)))
     LEFT JOIN events end_event ON ((end_event.id = eu_decisions.end_event_id)))
     LEFT JOIN geo_entities ON ((geo_entities.id = eu_decisions.geo_entity_id)))
     LEFT JOIN trade_codes sources ON ((((sources.type)::text = 'Source'::text) AND (sources.id = eu_decisions.source_id))))
     LEFT JOIN trade_codes terms ON ((((terms.type)::text = 'Term'::text) AND (terms.id = eu_decisions.term_id))));


--
-- Name: eu_listing_changes_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eu_listing_changes_mview (
    taxon_concept_id integer,
    id integer,
    original_taxon_concept_id integer,
    effective_at timestamp without time zone,
    species_listing_id integer,
    species_listing_name character varying(255),
    change_type_id integer,
    change_type_name character varying(255),
    designation_id integer,
    designation_name character varying(255),
    parent_id integer,
    party_id integer,
    party_iso_code character varying(255),
    party_full_name_en character varying(255),
    party_full_name_es character varying(255),
    party_full_name_fr character varying(255),
    ann_symbol character varying(255),
    full_note_en text,
    full_note_es text,
    full_note_fr text,
    short_note_en text,
    short_note_es text,
    short_note_fr text,
    display_in_index boolean,
    display_in_footnote boolean,
    hash_ann_symbol character varying(255),
    hash_ann_parent_symbol character varying(255),
    hash_full_note_en text,
    hash_full_note_es text,
    hash_full_note_fr text,
    inclusion_taxon_concept_id integer,
    inherited_short_note_en text,
    inherited_full_note_en text,
    inherited_short_note_es text,
    inherited_full_note_es text,
    inherited_short_note_fr text,
    inherited_full_note_fr text,
    auto_note_en text,
    auto_note_es text,
    auto_note_fr text,
    is_current boolean,
    explicit_change boolean,
    updated_at timestamp without time zone,
    show_in_history boolean,
    show_in_downloads boolean,
    show_in_timeline boolean,
    listed_geo_entities_ids integer[],
    excluded_geo_entities_ids integer[],
    excluded_taxon_concept_ids integer[],
    dirty boolean,
    expiry timestamp with time zone
);


--
-- Name: eu_regulations_applicability_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW eu_regulations_applicability_view AS
 WITH regulation_applicability_periods AS (
         SELECT DISTINCT events_1.effective_at,
            events_1.end_date
           FROM events events_1
          WHERE (((events_1.type)::text = 'EuRegulation'::text) AND (events_1.effective_at >= '1997-06-01 00:00:00'::timestamp without time zone))
          ORDER BY events_1.effective_at, events_1.end_date
        ), overlapping(start_date, end_date) AS (
         SELECT outer_i.effective_at,
                CASE
                    WHEN (inner_i.effective_at = outer_i.effective_at) THEN inner_i.end_date
                    ELSE inner_i.effective_at
                END AS effective_at
           FROM (regulation_applicability_periods outer_i
             JOIN regulation_applicability_periods inner_i ON (((outer_i.effective_at < inner_i.effective_at) AND (outer_i.end_date = inner_i.end_date))))
          ORDER BY inner_i.effective_at
        ), non_overlapping(start_date, end_date) AS (
         SELECT outer_i.effective_at,
            outer_i.end_date
           FROM (regulation_applicability_periods outer_i
             LEFT JOIN regulation_applicability_periods inner_i ON (((outer_i.effective_at < inner_i.effective_at) AND (outer_i.end_date = inner_i.end_date))))
          WHERE (inner_i.effective_at IS NULL)
        ), intervals(start_date, end_date) AS (
         SELECT i.start_date,
            min(i.end_date) AS min
           FROM ( SELECT overlapping.start_date,
                    overlapping.end_date
                   FROM overlapping
                UNION
                 SELECT non_overlapping.start_date,
                    non_overlapping.end_date
                   FROM non_overlapping) i
          GROUP BY i.start_date
        )
 SELECT (intervals.start_date)::date AS start_date,
    (intervals.end_date)::date AS end_date,
    array_agg(events.id) AS events_ids
   FROM (intervals
     JOIN events ON (((((events.type)::text = 'EuRegulation'::text) AND (events.effective_at <= intervals.start_date)) AND ((events.end_date >= intervals.end_date) OR (events.end_date IS NULL)))))
  GROUP BY intervals.start_date, intervals.end_date
  ORDER BY intervals.start_date;


--
-- Name: eu_species_listing_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eu_species_listing_mview (
    id integer,
    taxonomic_position character varying(255),
    kingdom_id integer,
    phylum_id integer,
    class_id integer,
    order_id integer,
    family_id integer,
    genus_id integer,
    kingdom_name text,
    phylum_name text,
    class_name text,
    order_name text,
    family_name text,
    genus_name text,
    species_name text,
    subspecies_name text,
    full_name character varying(255),
    author_year character varying(255),
    rank_name character varying(255),
    eu_listed boolean,
    eu_listing_original text,
    cites_listing_original text,
    original_taxon_concept_party_iso_code text,
    original_taxon_concept_full_name_with_spp text,
    original_taxon_concept_full_note_en text,
    original_taxon_concept_hash_full_note_en text,
    countries_ids_ary integer[],
    all_distribution text,
    all_distribution_iso_codes text,
    native_distribution text,
    introduced_distribution text,
    introduced_uncertain_distribution text,
    reintroduced_distribution text,
    extinct_distribution text,
    extinct_uncertain_distribution text,
    uncertain_distribution text
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: ft_trade_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ft_trade_shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geo_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geo_entities_id_seq OWNED BY geo_entities.id;


--
-- Name: geo_entity_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_entity_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: geo_entity_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geo_entity_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_entity_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geo_entity_types_id_seq OWNED BY geo_entity_types.id;


--
-- Name: geo_relationship_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_relationship_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: geo_relationship_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geo_relationship_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_relationship_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geo_relationship_types_id_seq OWNED BY geo_relationship_types.id;


--
-- Name: geo_relationships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_relationships (
    id integer NOT NULL,
    geo_entity_id integer NOT NULL,
    other_geo_entity_id integer NOT NULL,
    geo_relationship_type_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: geo_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geo_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geo_relationships_id_seq OWNED BY geo_relationships.id;


--
-- Name: instruments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instruments (
    id integer NOT NULL,
    designation_id integer,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instruments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instruments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instruments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instruments_id_seq OWNED BY instruments.id;


--
-- Name: iucn_mappings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE iucn_mappings (
    id integer NOT NULL,
    taxon_concept_id integer,
    iucn_taxon_id integer,
    iucn_taxon_name character varying(255),
    iucn_author character varying(255),
    iucn_category character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    details hstore,
    accepted_name_id integer
);


--
-- Name: iucn_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE iucn_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: iucn_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE iucn_mappings_id_seq OWNED BY iucn_mappings.id;


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE languages_id_seq OWNED BY languages.id;


--
-- Name: listing_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE listing_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: listing_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE listing_changes_id_seq OWNED BY listing_changes.id;


--
-- Name: listing_changes_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE listing_changes_mview (
    taxon_concept_id integer,
    id integer,
    original_taxon_concept_id integer,
    effective_at timestamp without time zone,
    species_listing_id integer,
    species_listing_name character varying(255),
    change_type_id integer,
    change_type_name character varying(255),
    designation_id integer,
    designation_name character varying(255),
    parent_id integer,
    party_id integer,
    party_iso_code character varying(255),
    ann_symbol character varying(255),
    full_note_en text,
    full_note_es text,
    full_note_fr text,
    short_note_en text,
    short_note_es text,
    short_note_fr text,
    display_in_index boolean,
    display_in_footnote boolean,
    hash_ann_symbol character varying(255),
    hash_ann_parent_symbol character varying(255),
    hash_full_note_en text,
    hash_full_note_es text,
    hash_full_note_fr text,
    inclusion_taxon_concept_id integer,
    inherited_short_note_en text,
    inherited_full_note_en text,
    auto_note text,
    is_current boolean,
    explicit_change boolean,
    countries_ids_ary integer[],
    updated_at timestamp without time zone,
    show_in_history boolean,
    show_in_downloads boolean,
    show_in_timeline boolean,
    dirty boolean,
    expiry timestamp with time zone
);


--
-- Name: listing_distributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE listing_distributions (
    id integer NOT NULL,
    listing_change_id integer NOT NULL,
    geo_entity_id integer NOT NULL,
    is_party boolean DEFAULT true NOT NULL,
    original_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: species_listings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE species_listings (
    id integer NOT NULL,
    designation_id integer NOT NULL,
    name character varying(255) NOT NULL,
    abbreviation character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: listing_changes_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW listing_changes_view AS
 SELECT listing_changes.id,
    listing_changes.taxon_concept_id,
    listing_changes.effective_at,
    listing_changes.species_listing_id,
    species_listings.abbreviation AS species_listing_name,
    listing_changes.change_type_id,
    change_types.name AS change_type_name,
    change_types.designation_id,
    designations.name AS designation_name,
    listing_distributions.geo_entity_id AS party_id,
    geo_entities.iso_code2 AS party_iso_code,
    annotations.symbol AS ann_symbol,
    annotations.full_note_en,
    annotations.full_note_es,
    annotations.full_note_fr,
    annotations.short_note_en,
    annotations.short_note_es,
    annotations.short_note_fr,
    annotations.display_in_index,
    annotations.display_in_footnote,
    hash_annotations.symbol AS hash_ann_symbol,
    hash_annotations.parent_symbol AS hash_ann_parent_symbol,
    hash_annotations.full_note_en AS hash_full_note_en,
    hash_annotations.full_note_es AS hash_full_note_es,
    hash_annotations.full_note_fr AS hash_full_note_fr,
    listing_changes.is_current,
    listing_changes.explicit_change,
    populations.countries_ids_ary
   FROM ((((((((listing_changes
     JOIN change_types ON ((listing_changes.change_type_id = change_types.id)))
     JOIN designations ON ((change_types.designation_id = designations.id)))
     LEFT JOIN species_listings ON ((listing_changes.species_listing_id = species_listings.id)))
     LEFT JOIN listing_distributions ON (((listing_changes.id = listing_distributions.listing_change_id) AND (listing_distributions.is_party = true))))
     LEFT JOIN geo_entities ON ((geo_entities.id = listing_distributions.geo_entity_id)))
     LEFT JOIN annotations ON ((annotations.id = listing_changes.annotation_id)))
     LEFT JOIN annotations hash_annotations ON ((hash_annotations.id = listing_changes.hash_annotation_id)))
     LEFT JOIN ( SELECT listing_distributions_1.listing_change_id,
            array_agg(geo_entities_1.id) AS countries_ids_ary
           FROM (listing_distributions listing_distributions_1
             JOIN geo_entities geo_entities_1 ON ((geo_entities_1.id = listing_distributions_1.geo_entity_id)))
          WHERE (NOT listing_distributions_1.is_party)
          GROUP BY listing_distributions_1.listing_change_id) populations ON ((populations.listing_change_id = listing_changes.id)))
  ORDER BY listing_changes.taxon_concept_id, listing_changes.effective_at,
        CASE
            WHEN ((change_types.name)::text = 'ADDITION'::text) THEN 0
            WHEN ((change_types.name)::text = 'RESERVATION'::text) THEN 1
            WHEN ((change_types.name)::text = 'RESERVATION_WITHDRAWAL'::text) THEN 2
            WHEN ((change_types.name)::text = 'DELETION'::text) THEN 3
            ELSE NULL::integer
        END;


--
-- Name: listing_distributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE listing_distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: listing_distributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE listing_distributions_id_seq OWNED BY listing_distributions.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_access_grants (
    id integer NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying(255) NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying(255)
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_access_tokens (
    id integer NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying(255) NOT NULL,
    refresh_token character varying(255),
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying(255)
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_applications (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    uid character varying(255) NOT NULL,
    secret character varying(255) NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: taxon_relationships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_relationships (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    other_taxon_concept_id integer NOT NULL,
    taxon_relationship_type_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: orphaned_taxon_concepts_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW orphaned_taxon_concepts_view AS
 SELECT tc.name_status,
    tc.id,
    tc.legacy_id,
    tc.legacy_trade_code,
    (tc.data -> 'rank_name'::text) AS rank_name,
    tc.full_name,
    tc.author_year,
    taxonomies.id AS taxonomy_id,
    taxonomies.name AS taxonomy_name,
    array_to_string(ARRAY[general_note.note, nomenclature_note.note, distribution_note.note], '
'::text) AS internal_notes,
    to_char(tc.created_at, 'DD/MM/YYYY'::text) AS created_at,
    uc.name AS created_by,
    to_char(tc.updated_at, 'DD/MM/YYYY'::text) AS updated_at,
    uu.name AS updated_by
   FROM (((((((((taxon_concepts tc
     JOIN taxonomies ON ((taxonomies.id = tc.taxonomy_id)))
     LEFT JOIN taxon_relationships tr1 ON ((tr1.taxon_concept_id = tc.id)))
     LEFT JOIN taxon_relationships tr2 ON ((tr2.other_taxon_concept_id = tc.id)))
     LEFT JOIN taxon_concepts children ON ((children.parent_id = tc.id)))
     LEFT JOIN comments general_note ON ((((general_note.commentable_id = tc.id) AND ((general_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((general_note.comment_type)::text = 'General'::text))))
     LEFT JOIN comments nomenclature_note ON ((((nomenclature_note.commentable_id = tc.id) AND ((nomenclature_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((nomenclature_note.comment_type)::text = 'Nomenclature'::text))))
     LEFT JOIN comments distribution_note ON ((((distribution_note.commentable_id = tc.id) AND ((distribution_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((distribution_note.comment_type)::text = 'Distribution'::text))))
     LEFT JOIN users uc ON ((tc.created_by_id = uc.id)))
     LEFT JOIN users uu ON ((tc.updated_by_id = uu.id)))
  WHERE ((((tc.parent_id IS NULL) AND (tr1.id IS NULL)) AND (tr2.id IS NULL)) AND (children.id IS NULL));


--
-- Name: preset_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE preset_tags (
    id integer NOT NULL,
    name character varying(255),
    model character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: preset_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE preset_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preset_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE preset_tags_id_seq OWNED BY preset_tags.id;


--
-- Name: proposal_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE proposal_details (
    id integer NOT NULL,
    document_id integer,
    proposal_nature text,
    proposal_outcome_id integer,
    representation text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: proposal_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE proposal_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposal_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE proposal_details_id_seq OWNED BY proposal_details.id;


--
-- Name: ranks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ranks (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    taxonomic_position character varying(255) DEFAULT '0'::character varying NOT NULL,
    fixed_order boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    display_name_en text NOT NULL,
    display_name_es text,
    display_name_fr text
);


--
-- Name: ranks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ranks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ranks_id_seq OWNED BY ranks.id;


--
-- Name: references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "references" (
    id integer NOT NULL,
    title text,
    year character varying(255),
    author character varying(255),
    citation text NOT NULL,
    publisher text,
    legacy_id integer,
    legacy_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updated_by_id integer,
    created_by_id integer
);


--
-- Name: references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE references_id_seq OWNED BY "references".id;


--
-- Name: references_legacy_id_mapping; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE references_legacy_id_mapping (
    id integer NOT NULL,
    legacy_id integer NOT NULL,
    legacy_type text NOT NULL,
    alias_legacy_id integer NOT NULL
);


--
-- Name: references_legacy_id_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE references_legacy_id_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: references_legacy_id_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE references_legacy_id_mapping_id_seq OWNED BY references_legacy_id_mapping.id;


--
-- Name: review_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE review_details (
    id integer NOT NULL,
    document_id integer,
    review_phase_id integer,
    process_stage_id integer,
    recommended_category_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: review_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE review_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE review_details_id_seq OWNED BY review_details.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: species_listings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE species_listings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: species_listings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE species_listings_id_seq OWNED BY species_listings.id;


--
-- Name: taxon_concept_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concept_references (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    reference_id integer NOT NULL,
    is_standard boolean DEFAULT false NOT NULL,
    is_cascaded boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    excluded_taxon_concepts_ids integer[],
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: species_reference_output_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW species_reference_output_view AS
 SELECT st.id,
    st.legacy_id,
    (st.data -> 'kingdom_name'::text) AS kingdom_name,
    (st.data -> 'phylum_name'::text) AS phylum_name,
    (st.data -> 'class_name'::text) AS class_name,
    (st.data -> 'order_name'::text) AS order_name,
    (st.data -> 'family_name'::text) AS family_name,
    (st.data -> 'genus_name'::text) AS genus_name,
    (st.data -> 'species_name'::text) AS species_name,
    st.full_name,
    st.author_year,
    st.taxonomic_position,
    (st.data -> 'rank_name'::text) AS rank_name,
    st.name_status,
    taxonomies.name AS taxonomy,
    taxonomies.id AS taxonomy_id,
    rf.citation AS reference,
    rf.id AS reference_id,
    rf.legacy_id AS reference_legacy_id,
    to_char(r.created_at, 'DD/MM/YYYY'::text) AS created_at,
    uc.name AS created_by,
    to_char(r.updated_at, 'DD/MM/YYYY'::text) AS updated_at,
    uu.name AS updated_by
   FROM (((((taxon_concepts st
     JOIN taxonomies ON ((taxonomies.id = st.taxonomy_id)))
     LEFT JOIN taxon_concept_references r ON (((r.taxon_concept_id = st.id) AND (r.is_standard IS FALSE))))
     LEFT JOIN "references" rf ON ((r.reference_id = rf.id)))
     LEFT JOIN users uc ON ((r.created_by_id = uc.id)))
     LEFT JOIN users uu ON ((r.updated_by_id = uu.id)))
  WHERE ((st.name_status)::text = ANY ((ARRAY['A'::character varying, 'N'::character varying])::text[]));


--
-- Name: standard_reference_output_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW standard_reference_output_view AS
 WITH RECURSIVE inherited_references AS (
         SELECT taxon_concept_references_1.id,
            taxon_concept_references_1.taxon_concept_id,
            taxon_concept_references_1.excluded_taxon_concepts_ids AS exclusions,
            taxon_concept_references_1.is_cascaded
           FROM taxon_concept_references taxon_concept_references_1
          WHERE (taxon_concept_references_1.is_standard = true)
        UNION
         SELECT d.id,
            low.id,
            d.exclusions,
            d.is_cascaded
           FROM (taxon_concepts low
             JOIN inherited_references d ON ((d.taxon_concept_id = low.parent_id)))
          WHERE ((NOT (COALESCE(d.exclusions, ARRAY[]::integer[]) @> ARRAY[low.id])) AND d.is_cascaded)
        )
 SELECT taxon_concepts.id,
    taxon_concepts.legacy_id,
    (taxon_concepts.data -> 'kingdom_name'::text) AS kingdom_name,
    (taxon_concepts.data -> 'phylum_name'::text) AS phylum_name,
    (taxon_concepts.data -> 'class_name'::text) AS class_name,
    (taxon_concepts.data -> 'order_name'::text) AS order_name,
    (taxon_concepts.data -> 'family_name'::text) AS family_name,
    (taxon_concepts.data -> 'genus_name'::text) AS genus_name,
    (taxon_concepts.data -> 'species_name'::text) AS species_name,
    taxon_concepts.full_name,
    taxon_concepts.author_year,
    taxon_concepts.taxonomic_position,
    (taxon_concepts.data -> 'rank_name'::text) AS rank_name,
    taxon_concepts.name_status,
    taxonomies.name AS taxonomy,
    taxonomies.id AS taxonomy_id,
    r.id AS reference_id,
    r.legacy_id AS reference_legacy_id,
    r.citation,
        CASE
            WHEN ((issued_for.id IS NOT NULL) AND (issued_for.id <> taxon_concepts.id)) THEN issued_for.full_name
            ELSE ''::character varying
        END AS inherited_from,
        CASE
            WHEN ((issued_for.id IS NOT NULL) AND (issued_for.id = taxon_concepts.id)) THEN array_to_string(ARRAY( SELECT taxon_concepts_1.full_name
               FROM (unnest(inherited_references.exclusions) s(s)
                 JOIN taxon_concepts taxon_concepts_1 ON ((taxon_concepts_1.id = s.s)))
              WHERE (s.s IS NOT NULL)), ', '::text)
            ELSE ''::text
        END AS exclusions,
    inherited_references.is_cascaded,
    to_char(taxon_concept_references.created_at, 'DD/MM/YYYY'::text) AS created_at,
    uc.name AS created_by,
    to_char(taxon_concept_references.updated_at, 'DD/MM/YYYY'::text) AS updated_at,
    uu.name AS updated_by
   FROM (((((((taxon_concepts
     JOIN taxonomies ON ((taxonomies.id = taxon_concepts.taxonomy_id)))
     LEFT JOIN inherited_references ON ((taxon_concepts.id = inherited_references.taxon_concept_id)))
     LEFT JOIN taxon_concept_references ON ((taxon_concept_references.id = inherited_references.id)))
     LEFT JOIN "references" r ON ((r.id = taxon_concept_references.reference_id)))
     LEFT JOIN taxon_concepts issued_for ON ((issued_for.id = taxon_concept_references.taxon_concept_id)))
     LEFT JOIN users uc ON ((taxon_concept_references.created_by_id = uc.id)))
     LEFT JOIN users uu ON ((taxon_concept_references.updated_by_id = uu.id)))
  WHERE ((taxon_concepts.name_status)::text = ANY ((ARRAY['N'::character varying, 'A'::character varying])::text[]))
  ORDER BY r.citation;


--
-- Name: synonyms_and_trade_names_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW synonyms_and_trade_names_view AS
 SELECT st.name_status,
    st.id,
    st.legacy_id,
    st.legacy_trade_code,
    (st.data -> 'rank_name'::text) AS rank_name,
    st.full_name,
    st.author_year,
    a.full_name AS accepted_full_name,
    a.author_year AS accepted_author_year,
    a.id AS accepted_id,
    (a.data -> 'rank_name'::text) AS accepted_rank_name,
    a.name_status AS accepted_name_status,
    (a.data -> 'kingdom_name'::text) AS accepted_kingdom_name,
    (a.data -> 'phylum_name'::text) AS accepted_phylum_name,
    (a.data -> 'class_name'::text) AS accepted_class_name,
    (a.data -> 'order_name'::text) AS accepted_order_name,
    (a.data -> 'family_name'::text) AS accepted_family_name,
    (a.data -> 'genus_name'::text) AS accepted_genus_name,
    (a.data -> 'species_name'::text) AS accepted_species_name,
    taxonomies.id AS taxonomy_id,
    taxonomies.name AS taxonomy_name,
    array_to_string(ARRAY[general_note.note, nomenclature_note.note, distribution_note.note], '
'::text) AS internal_notes,
    to_char(st.created_at, 'DD/MM/YYYY'::text) AS created_at,
    uc.name AS created_by,
    to_char(st.updated_at, 'DD/MM/YYYY'::text) AS updated_at,
    uu.name AS updated_by
   FROM ((((((((taxon_concepts st
     JOIN taxonomies ON ((taxonomies.id = st.taxonomy_id)))
     LEFT JOIN taxon_relationships ON ((taxon_relationships.other_taxon_concept_id = st.id)))
     LEFT JOIN taxon_concepts a ON ((taxon_relationships.taxon_concept_id = a.id)))
     LEFT JOIN comments general_note ON ((((general_note.commentable_id = st.id) AND ((general_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((general_note.comment_type)::text = 'General'::text))))
     LEFT JOIN comments nomenclature_note ON ((((nomenclature_note.commentable_id = st.id) AND ((nomenclature_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((nomenclature_note.comment_type)::text = 'Nomenclature'::text))))
     LEFT JOIN comments distribution_note ON ((((distribution_note.commentable_id = st.id) AND ((distribution_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((distribution_note.comment_type)::text = 'Distribution'::text))))
     LEFT JOIN users uc ON ((st.created_by_id = uc.id)))
     LEFT JOIN users uu ON ((st.updated_by_id = uu.id)))
  WHERE ((st.name_status)::text = ANY ((ARRAY['S'::character varying, 'T'::character varying])::text[]));


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255),
    tagger_id integer,
    tagger_type character varying(255),
    context character varying(128),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: taxon_commons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_commons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_commons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_commons_id_seq OWNED BY taxon_commons.id;


--
-- Name: taxon_concept_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_concept_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_concept_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_concept_references_id_seq OWNED BY taxon_concept_references.id;


--
-- Name: taxon_concepts_distributions_view; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concepts_distributions_view (
    id integer,
    legacy_id integer,
    phylum_name text,
    class_name text,
    order_name text,
    family_name text,
    full_name character varying(255),
    rank_name text,
    geo_entity_type character varying(255),
    geo_entity_name character varying(255),
    geo_entity_iso_code2 character varying(255),
    tags text,
    reference_full text,
    reference_id integer,
    reference_legacy_id integer,
    taxonomy_name character varying(255),
    taxonomic_position character varying(255),
    taxonomy_id integer,
    internal_notes text,
    created_at text,
    created_by character varying(255),
    updated_at text,
    updated_by character varying(255)
);


--
-- Name: taxon_concepts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_concepts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_concepts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_concepts_id_seq OWNED BY taxon_concepts.id;


--
-- Name: taxon_concepts_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concepts_mview (
    id integer,
    parent_id integer,
    taxonomy_id integer,
    taxonomy_is_cites_eu boolean,
    full_name character varying(255),
    name_status character varying(255),
    rank_id integer,
    rank_name character varying(255),
    rank_display_name_en text,
    rank_display_name_es text,
    rank_display_name_fr text,
    spp boolean,
    cites_accepted boolean,
    kingdom_position integer,
    taxonomic_position character varying(255),
    kingdom_name text,
    phylum_name text,
    class_name text,
    order_name text,
    family_name text,
    subfamily_name text,
    genus_name text,
    species_name text,
    subspecies_name text,
    kingdom_id integer,
    phylum_id integer,
    class_id integer,
    order_id integer,
    family_id integer,
    subfamily_id integer,
    genus_id integer,
    species_id integer,
    subspecies_id integer,
    cites_i boolean,
    cites_ii boolean,
    cites_iii boolean,
    cites_listed boolean,
    cites_listed_descendants boolean,
    cites_show boolean,
    cites_status text,
    cites_listing_original text,
    cites_listing text,
    cites_listing_updated_at timestamp without time zone,
    ann_symbol text,
    hash_ann_symbol text,
    hash_ann_parent_symbol text,
    eu_listed boolean,
    eu_show boolean,
    eu_status text,
    eu_listing_original text,
    eu_listing text,
    eu_listing_updated_at timestamp without time zone,
    cms_listed boolean,
    cms_show boolean,
    cms_status text,
    cms_listing_original text,
    cms_listing text,
    cms_listing_updated_at timestamp without time zone,
    species_listings_ids integer[],
    species_listings_ids_aggregated integer[],
    author_year character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    dependents_updated_at timestamp without time zone,
    taxon_concept_id_com integer,
    english_names_ary character varying[],
    spanish_names_ary character varying[],
    french_names_ary character varying[],
    taxon_concept_id_syn integer,
    synonyms_ary character varying[],
    synonyms_author_years_ary character varying[],
    subspecies_not_listed_ary character varying[],
    countries_ids_ary integer[],
    all_distribution_iso_codes_ary character varying[],
    all_distribution_ary character varying[],
    native_distribution_ary character varying[],
    introduced_distribution_ary character varying[],
    introduced_uncertain_distribution_ary character varying[],
    reintroduced_distribution_ary character varying[],
    extinct_distribution_ary character varying[],
    extinct_uncertain_distribution_ary character varying[],
    uncertain_distribution_ary character varying[],
    all_distribution_ary_en character varying[],
    native_distribution_ary_en character varying[],
    introduced_distribution_ary_en character varying[],
    introduced_uncertain_distribution_ary_en character varying[],
    reintroduced_distribution_ary_en character varying[],
    extinct_distribution_ary_en character varying[],
    extinct_uncertain_distribution_ary_en character varying[],
    uncertain_distribution_ary_en character varying[],
    all_distribution_ary_es character varying[],
    native_distribution_ary_es character varying[],
    introduced_distribution_ary_es character varying[],
    introduced_uncertain_distribution_ary_es character varying[],
    reintroduced_distribution_ary_es character varying[],
    extinct_distribution_ary_es character varying[],
    extinct_uncertain_distribution_ary_es character varying[],
    uncertain_distribution_ary_es character varying[],
    all_distribution_ary_fr character varying[],
    native_distribution_ary_fr character varying[],
    introduced_distribution_ary_fr character varying[],
    introduced_uncertain_distribution_ary_fr character varying[],
    reintroduced_distribution_ary_fr character varying[],
    extinct_distribution_ary_fr character varying[],
    extinct_uncertain_distribution_ary_fr character varying[],
    uncertain_distribution_ary_fr character varying[],
    show_in_species_plus boolean,
    dirty boolean,
    expiry timestamp with time zone
);


--
-- Name: taxon_concepts_names_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW taxon_concepts_names_view AS
 SELECT taxon_concepts.id,
    taxon_concepts.legacy_id,
    (taxon_concepts.data -> 'kingdom_name'::text) AS kingdom_name,
    (taxon_concepts.data -> 'phylum_name'::text) AS phylum_name,
    (taxon_concepts.data -> 'class_name'::text) AS class_name,
    (taxon_concepts.data -> 'order_name'::text) AS order_name,
    (taxon_concepts.data -> 'family_name'::text) AS family_name,
    (taxon_concepts.data -> 'genus_name'::text) AS genus_name,
    (taxon_concepts.data -> 'species_name'::text) AS species_name,
    taxon_concepts.full_name,
    taxon_concepts.author_year,
    (taxon_concepts.data -> 'rank_name'::text) AS rank_name,
    taxon_concepts.name_status,
    taxon_concepts.taxonomic_position,
    taxon_concepts.taxonomy_id,
    taxonomies.name AS taxonomy_name,
    array_to_string(ARRAY[general_note.note, nomenclature_note.note, distribution_note.note], '
'::text) AS internal_notes,
    to_char(taxon_concepts.created_at, 'DD/MM/YYYY'::text) AS created_at,
    uc.name AS created_by,
    to_char(taxon_concepts.updated_at, 'DD/MM/YYYY'::text) AS updated_at,
    uu.name AS updated_by
   FROM ((((((taxon_concepts
     JOIN taxonomies ON ((taxonomies.id = taxon_concepts.taxonomy_id)))
     LEFT JOIN comments general_note ON ((((general_note.commentable_id = taxon_concepts.id) AND ((general_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((general_note.comment_type)::text = 'General'::text))))
     LEFT JOIN comments nomenclature_note ON ((((nomenclature_note.commentable_id = taxon_concepts.id) AND ((nomenclature_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((nomenclature_note.comment_type)::text = 'Nomenclature'::text))))
     LEFT JOIN comments distribution_note ON ((((distribution_note.commentable_id = taxon_concepts.id) AND ((distribution_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((distribution_note.comment_type)::text = 'Distribution'::text))))
     LEFT JOIN users uc ON ((taxon_concepts.created_by_id = uc.id)))
     LEFT JOIN users uu ON ((taxon_concepts.updated_by_id = uu.id)));


--
-- Name: taxon_instruments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_instruments (
    id integer NOT NULL,
    taxon_concept_id integer,
    instrument_id integer,
    effective_from timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: taxon_instruments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_instruments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_instruments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_instruments_id_seq OWNED BY taxon_instruments.id;


--
-- Name: taxon_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_names (
    id integer NOT NULL,
    scientific_name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_names_id_seq OWNED BY taxon_names.id;


--
-- Name: taxon_relationship_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_relationship_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    is_intertaxonomic boolean DEFAULT false NOT NULL,
    is_bidirectional boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_relationship_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_relationship_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_relationship_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_relationship_types_id_seq OWNED BY taxon_relationship_types.id;


--
-- Name: taxon_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_relationships_id_seq OWNED BY taxon_relationships.id;


--
-- Name: taxonomies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxonomies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxonomies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxonomies_id_seq OWNED BY taxonomies.id;


--
-- Name: term_trade_codes_pairs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE term_trade_codes_pairs (
    id integer NOT NULL,
    term_id integer NOT NULL,
    trade_code_id integer,
    trade_code_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: term_trade_codes_pairs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE term_trade_codes_pairs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: term_trade_codes_pairs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE term_trade_codes_pairs_id_seq OWNED BY term_trade_codes_pairs.id;


--
-- Name: trade_annual_report_uploads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_annual_report_uploads (
    id integer NOT NULL,
    created_by integer,
    updated_by integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_done boolean DEFAULT false,
    number_of_rows integer,
    csv_source_file text,
    trading_country_id integer NOT NULL,
    point_of_view character varying(255) DEFAULT 'E'::character varying NOT NULL,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: trade_annual_report_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_annual_report_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_annual_report_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_annual_report_uploads_id_seq OWNED BY trade_annual_report_uploads.id;


--
-- Name: trade_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_codes_id_seq OWNED BY trade_codes.id;


--
-- Name: trade_permits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_permits (
    id integer NOT NULL,
    number character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trade_permits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_permits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_permits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_permits_id_seq OWNED BY trade_permits.id;


--
-- Name: trade_restriction_purposes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_restriction_purposes (
    id integer NOT NULL,
    trade_restriction_id integer,
    purpose_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: trade_restriction_purposes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_restriction_purposes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_restriction_purposes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_restriction_purposes_id_seq OWNED BY trade_restriction_purposes.id;


--
-- Name: trade_restriction_sources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_restriction_sources (
    id integer NOT NULL,
    trade_restriction_id integer,
    source_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: trade_restriction_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_restriction_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_restriction_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_restriction_sources_id_seq OWNED BY trade_restriction_sources.id;


--
-- Name: trade_restriction_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_restriction_terms (
    id integer NOT NULL,
    trade_restriction_id integer,
    term_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    updated_by_id integer
);


--
-- Name: trade_restriction_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_restriction_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_restriction_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_restriction_terms_id_seq OWNED BY trade_restriction_terms.id;


--
-- Name: trade_restrictions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_restrictions (
    id integer NOT NULL,
    is_current boolean DEFAULT true,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    geo_entity_id integer,
    quota double precision,
    publication_date timestamp without time zone,
    notes text,
    type character varying(255),
    unit_id integer,
    taxon_concept_id integer,
    public_display boolean DEFAULT true,
    url text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    start_notification_id integer,
    end_notification_id integer,
    excluded_taxon_concepts_ids integer[],
    original_id integer,
    updated_by_id integer,
    created_by_id integer,
    internal_notes text
);


--
-- Name: trade_restrictions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_restrictions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_restrictions_id_seq OWNED BY trade_restrictions.id;


--
-- Name: trade_sandbox_template; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_sandbox_template (
    id integer NOT NULL,
    appendix character varying(255),
    taxon_name character varying(255),
    term_code character varying(255),
    quantity character varying(255),
    unit_code character varying(255),
    trading_partner character varying(255),
    country_of_origin character varying(255),
    export_permit text,
    origin_permit text,
    purpose_code character varying(255),
    source_code character varying(255),
    year character varying(255),
    import_permit text,
    reported_taxon_concept_id integer,
    taxon_concept_id integer
);


--
-- Name: trade_sandbox_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_sandbox_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_sandbox_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_sandbox_template_id_seq OWNED BY trade_sandbox_template.id;


--
-- Name: trade_shipments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_shipments (
    id integer NOT NULL,
    source_id integer,
    unit_id integer,
    purpose_id integer,
    term_id integer NOT NULL,
    quantity numeric NOT NULL,
    appendix character varying(255) NOT NULL,
    trade_annual_report_upload_id integer,
    exporter_id integer NOT NULL,
    importer_id integer NOT NULL,
    country_of_origin_id integer,
    reported_by_exporter boolean DEFAULT true NOT NULL,
    taxon_concept_id integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id integer,
    reported_taxon_concept_id integer,
    import_permit_number text,
    export_permit_number text,
    origin_permit_number text,
    legacy_shipment_number integer,
    import_permits_ids integer[],
    export_permits_ids integer[],
    origin_permits_ids integer[],
    updated_by_id integer,
    created_by_id integer
);


--
-- Name: trade_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_shipments_id_seq OWNED BY trade_shipments.id;


--
-- Name: trade_shipments_with_taxa_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW trade_shipments_with_taxa_view AS
 SELECT shipments.id,
    shipments.source_id,
    shipments.unit_id,
    shipments.purpose_id,
    shipments.term_id,
    shipments.quantity,
    shipments.appendix,
    shipments.trade_annual_report_upload_id,
    shipments.exporter_id,
    shipments.importer_id,
    shipments.country_of_origin_id,
    shipments.reported_by_exporter,
    shipments.taxon_concept_id,
    shipments.year,
    shipments.created_at,
    shipments.updated_at,
    shipments.sandbox_id,
    shipments.reported_taxon_concept_id,
    shipments.import_permit_number,
    shipments.export_permit_number,
    shipments.origin_permit_number,
    shipments.legacy_shipment_number,
    shipments.import_permits_ids,
    shipments.export_permits_ids,
    shipments.origin_permits_ids,
    shipments.updated_by_id,
    shipments.created_by_id,
    taxon_concepts.full_name AS taxon_concept_full_name,
    taxon_concepts.author_year AS taxon_concept_author_year,
    taxon_concepts.name_status AS taxon_concept_name_status,
    taxon_concepts.rank_id AS taxon_concept_rank_id,
    ((taxon_concepts.data -> 'kingdom_id'::text))::integer AS taxon_concept_kingdom_id,
    ((taxon_concepts.data -> 'phylum_id'::text))::integer AS taxon_concept_phylum_id,
    ((taxon_concepts.data -> 'class_id'::text))::integer AS taxon_concept_class_id,
    ((taxon_concepts.data -> 'order_id'::text))::integer AS taxon_concept_order_id,
    ((taxon_concepts.data -> 'family_id'::text))::integer AS taxon_concept_family_id,
    ((taxon_concepts.data -> 'subfamily_id'::text))::integer AS taxon_concept_subfamily_id,
    ((taxon_concepts.data -> 'genus_id'::text))::integer AS taxon_concept_genus_id,
    ((taxon_concepts.data -> 'species_id'::text))::integer AS taxon_concept_species_id,
    (taxon_concepts.data -> 'family_name'::text) AS taxon_concept_family_name,
    reported_taxon_concepts.full_name AS reported_taxon_concept_full_name,
    reported_taxon_concepts.author_year AS reported_taxon_concept_author_year,
    reported_taxon_concepts.name_status AS reported_taxon_concept_name_status,
    reported_taxon_concepts.rank_id AS reported_taxon_concept_rank_id,
    ((reported_taxon_concepts.data -> 'kingdom_id'::text))::integer AS reported_taxon_concept_kingdom_id,
    ((reported_taxon_concepts.data -> 'phylum_id'::text))::integer AS reported_taxon_concept_phylum_id,
    ((reported_taxon_concepts.data -> 'class_id'::text))::integer AS reported_taxon_concept_class_id,
    ((reported_taxon_concepts.data -> 'order_id'::text))::integer AS reported_taxon_concept_order_id,
    ((reported_taxon_concepts.data -> 'family_id'::text))::integer AS reported_taxon_concept_family_id,
    ((reported_taxon_concepts.data -> 'subfamily_id'::text))::integer AS reported_taxon_concept_subfamily_id,
    ((reported_taxon_concepts.data -> 'genus_id'::text))::integer AS reported_taxon_concept_genus_id,
    ((reported_taxon_concepts.data -> 'species_id'::text))::integer AS reported_taxon_concept_species_id
   FROM ((trade_shipments shipments
     JOIN taxon_concepts ON ((shipments.taxon_concept_id = taxon_concepts.id)))
     LEFT JOIN taxon_concepts reported_taxon_concepts ON ((shipments.reported_taxon_concept_id = reported_taxon_concepts.id)));


--
-- Name: trade_taxon_concept_term_pairs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_taxon_concept_term_pairs (
    id integer NOT NULL,
    taxon_concept_id integer,
    term_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trade_taxon_concept_term_pairs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_taxon_concept_term_pairs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_taxon_concept_term_pairs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_taxon_concept_term_pairs_id_seq OWNED BY trade_taxon_concept_term_pairs.id;


--
-- Name: trade_trade_data_downloads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_trade_data_downloads (
    id integer NOT NULL,
    user_ip character varying(255),
    report_type character varying(255),
    year_from integer,
    year_to integer,
    taxon character varying(255),
    appendix character varying(255),
    importer character varying(255),
    exporter character varying(255),
    origin character varying(255),
    term character varying(255),
    unit character varying(255),
    source character varying(255),
    purpose character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    number_of_rows integer,
    city character varying,
    country character varying,
    organization character varying
);


--
-- Name: trade_trade_data_downloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_trade_data_downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_trade_data_downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_trade_data_downloads_id_seq OWNED BY trade_trade_data_downloads.id;


--
-- Name: trade_validation_rules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_validation_rules (
    id integer NOT NULL,
    valid_values_view character varying(255),
    type character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    format_re character varying(255),
    run_order integer NOT NULL,
    column_names character varying(255)[],
    is_primary boolean DEFAULT true NOT NULL,
    scope hstore,
    is_strict boolean DEFAULT false NOT NULL
);


--
-- Name: trade_validation_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_validation_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_validation_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_validation_rules_id_seq OWNED BY trade_validation_rules.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: valid_appendix_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_appendix_view AS
 SELECT appendix.appendix
   FROM unnest(ARRAY['I'::text, 'II'::text, 'III'::text, 'N'::text]) appendix(appendix);


--
-- Name: valid_country_of_origin_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_country_of_origin_view AS
 SELECT geo_entities.iso_code2 AS country_of_origin
   FROM (geo_entities
     JOIN geo_entity_types ON ((geo_entity_types.id = geo_entities.geo_entity_type_id)))
  WHERE ((geo_entity_types.name)::text = ANY ((ARRAY['COUNTRY'::character varying, 'TERRITORY'::character varying, 'TRADE_ENTITY'::character varying])::text[]));


--
-- Name: valid_purpose_code_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_purpose_code_view AS
 SELECT trade_codes.code AS purpose_code
   FROM trade_codes
  WHERE ((trade_codes.type)::text = 'Purpose'::text);


--
-- Name: valid_source_code_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_source_code_view AS
 SELECT trade_codes.code AS source_code
   FROM trade_codes
  WHERE ((trade_codes.type)::text = 'Source'::text);


--
-- Name: valid_taxon_concept_annex_year_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE valid_taxon_concept_annex_year_mview (
    taxon_concept_id integer,
    annex character varying(255),
    effective_from timestamp without time zone,
    effective_to timestamp without time zone
);


--
-- Name: valid_taxon_concept_appendix_year_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE valid_taxon_concept_appendix_year_mview (
    taxon_concept_id integer,
    appendix character varying(255),
    effective_from timestamp without time zone,
    effective_to timestamp without time zone
);


--
-- Name: valid_taxon_concept_country_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_taxon_concept_country_view AS
 SELECT taxon_concepts.id AS taxon_concept_id,
    geo_entities.iso_code2,
    geo_entities.id AS geo_entity_id
   FROM (((taxon_concepts
     JOIN taxonomies ON (((taxonomies.id = taxon_concepts.taxonomy_id) AND ((taxonomies.name)::text = 'CITES_EU'::text))))
     JOIN distributions ON ((distributions.taxon_concept_id = taxon_concepts.id)))
     JOIN geo_entities ON ((geo_entities.id = distributions.geo_entity_id)));


--
-- Name: valid_taxon_concept_country_of_origin_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_taxon_concept_country_of_origin_view AS
 SELECT valid_taxon_concept_country_view.taxon_concept_id,
    valid_taxon_concept_country_view.iso_code2 AS country_of_origin,
    valid_taxon_concept_country_view.geo_entity_id AS country_of_origin_id
   FROM valid_taxon_concept_country_view;


--
-- Name: valid_taxon_concept_exporter_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_taxon_concept_exporter_view AS
 SELECT valid_taxon_concept_country_view.taxon_concept_id,
    valid_taxon_concept_country_view.iso_code2 AS exporter,
    valid_taxon_concept_country_view.geo_entity_id AS exporter_id
   FROM valid_taxon_concept_country_view;


--
-- Name: valid_taxon_concept_term_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_taxon_concept_term_view AS
 WITH RECURSIVE self_and_descendants(id, pair_id, term_id) AS (
         SELECT taxon_concepts.id,
            trade_taxon_concept_term_pairs.id,
            trade_taxon_concept_term_pairs.term_id
           FROM (trade_taxon_concept_term_pairs
             JOIN taxon_concepts ON ((trade_taxon_concept_term_pairs.taxon_concept_id = taxon_concepts.id)))
          WHERE ((taxon_concepts.name_status)::text = 'A'::text)
        UNION
         SELECT hi.id,
            d.pair_id,
            d.term_id
           FROM (taxon_concepts hi
             JOIN self_and_descendants d ON ((d.id = hi.parent_id)))
          WHERE ((hi.name_status)::text = 'A'::text)
        ), taxa_with_terms AS (
         SELECT self_and_descendants.id AS taxon_concept_id,
            terms.code AS term_code,
            self_and_descendants.term_id
           FROM ((self_and_descendants
             JOIN trade_taxon_concept_term_pairs ON ((trade_taxon_concept_term_pairs.id = self_and_descendants.pair_id)))
             JOIN trade_codes terms ON (((terms.id = trade_taxon_concept_term_pairs.term_id) AND ((terms.type)::text = 'Term'::text))))
        ), hybrids_with_terms AS (
         SELECT rel.other_taxon_concept_id AS taxon_concept_id,
            taxa_with_terms.term_code,
            taxa_with_terms.term_id
           FROM ((taxa_with_terms
             JOIN taxon_relationships rel ON ((rel.taxon_concept_id = taxa_with_terms.taxon_concept_id)))
             JOIN taxon_relationship_types rel_type ON (((rel.taxon_relationship_type_id = rel_type.id) AND ((rel_type.name)::text = 'HAS_HYBRID'::text))))
        )
 SELECT taxa_with_terms.taxon_concept_id,
    taxa_with_terms.term_code,
    taxa_with_terms.term_id
   FROM taxa_with_terms
UNION
 SELECT hybrids_with_terms.taxon_concept_id,
    hybrids_with_terms.term_code,
    hybrids_with_terms.term_id
   FROM hybrids_with_terms;


--
-- Name: valid_taxon_name_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_taxon_name_view AS
 SELECT taxon_concepts.full_name AS taxon_name
   FROM (taxon_concepts
     JOIN taxonomies ON ((taxonomies.id = taxon_concepts.taxonomy_id)))
  WHERE ((taxonomies.name)::text = 'CITES_EU'::text);


--
-- Name: valid_term_code_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_term_code_view AS
 SELECT trade_codes.code AS term_code
   FROM trade_codes
  WHERE ((trade_codes.type)::text = 'Term'::text);


--
-- Name: valid_term_purpose_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_term_purpose_view AS
 SELECT terms.code AS term_code,
    terms.id AS term_id,
    purposes.code AS purpose_code,
    purposes.id AS purpose_id
   FROM ((term_trade_codes_pairs
     JOIN trade_codes purposes ON ((((purposes.id = term_trade_codes_pairs.trade_code_id) AND ((term_trade_codes_pairs.trade_code_type)::text = 'Purpose'::text)) AND ((purposes.type)::text = 'Purpose'::text))))
     JOIN trade_codes terms ON ((terms.id = term_trade_codes_pairs.term_id)))
UNION
 SELECT terms.code AS term_code,
    terms.id AS term_id,
    NULL::character varying AS purpose_code,
    NULL::integer AS purpose_id
   FROM (term_trade_codes_pairs
     JOIN trade_codes terms ON ((terms.id = term_trade_codes_pairs.term_id)))
  WHERE (((term_trade_codes_pairs.trade_code_type)::text = 'Purpose'::text) AND (term_trade_codes_pairs.trade_code_id IS NULL));


--
-- Name: valid_term_unit_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_term_unit_view AS
 SELECT terms.code AS term_code,
    terms.id AS term_id,
    units.code AS unit_code,
    units.id AS unit_id
   FROM ((term_trade_codes_pairs
     JOIN trade_codes units ON ((((units.id = term_trade_codes_pairs.trade_code_id) AND ((term_trade_codes_pairs.trade_code_type)::text = 'Unit'::text)) AND ((units.type)::text = 'Unit'::text))))
     JOIN trade_codes terms ON ((terms.id = term_trade_codes_pairs.term_id)))
UNION
 SELECT terms.code AS term_code,
    terms.id AS term_id,
    NULL::character varying AS unit_code,
    NULL::integer AS unit_id
   FROM (term_trade_codes_pairs
     JOIN trade_codes terms ON ((terms.id = term_trade_codes_pairs.term_id)))
  WHERE (((term_trade_codes_pairs.trade_code_type)::text = 'Unit'::text) AND (term_trade_codes_pairs.trade_code_id IS NULL));


--
-- Name: valid_trading_partner_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_trading_partner_view AS
 SELECT geo_entities.iso_code2 AS trading_partner
   FROM (geo_entities
     JOIN geo_entity_types ON ((geo_entity_types.id = geo_entities.geo_entity_type_id)))
  WHERE ((geo_entity_types.name)::text = ANY ((ARRAY['COUNTRY'::character varying, 'TERRITORY'::character varying, 'TRADE_ENTITY'::character varying])::text[]));


--
-- Name: valid_unit_code_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW valid_unit_code_view AS
 SELECT trade_codes.code AS unit_code
   FROM trade_codes
  WHERE ((trade_codes.type)::text = 'Unit'::text);


--
-- Name: year_annual_reports_by_countries; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW year_annual_reports_by_countries AS
 SELECT row_number() OVER (ORDER BY b.name_en, b.year DESC) AS no,
    b.name_en,
    b.year,
        CASE
            WHEN (b.sum = 0) THEN 'I/E'::text
            WHEN (b.sum = 1) THEN 'E'::text
            WHEN (b.sum = (-1)) THEN 'I'::text
            ELSE NULL::text
        END AS reporter_type,
    b.year_created
   FROM ( SELECT a.name_en,
            a.year,
            sum(a.type) AS sum,
            a.year_created
           FROM ( SELECT DISTINCT g.name_en,
                    t.year,
                    1 AS type,
                    date_part('year'::text, t.created_at) AS year_created
                   FROM (trade_shipments t
                     LEFT JOIN geo_entities g ON ((t.exporter_id = g.id)))
                  WHERE (t.reported_by_exporter = true)
                UNION ALL
                 SELECT DISTINCT g.name_en,
                    t.year,
                    (-1) AS type,
                    date_part('year'::text, t.created_at) AS year_created
                   FROM (trade_shipments t
                     LEFT JOIN geo_entities g ON ((t.importer_id = g.id)))
                  WHERE (t.reported_by_exporter = false)) a
          GROUP BY a.name_en, a.year, a.year_created) b;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotations ALTER COLUMN id SET DEFAULT nextval('annotations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY change_types ALTER COLUMN id SET DEFAULT nextval('change_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cites_suspension_confirmations ALTER COLUMN id SET DEFAULT nextval('cites_suspension_confirmations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cms_mappings ALTER COLUMN id SET DEFAULT nextval('cms_mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY common_names ALTER COLUMN id SET DEFAULT nextval('common_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY designation_geo_entities ALTER COLUMN id SET DEFAULT nextval('designation_geo_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY designations ALTER COLUMN id SET DEFAULT nextval('designations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY distribution_references ALTER COLUMN id SET DEFAULT nextval('distribution_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions ALTER COLUMN id SET DEFAULT nextval('distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_geo_entities ALTER COLUMN id SET DEFAULT nextval('document_citation_geo_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_taxon_concepts ALTER COLUMN id SET DEFAULT nextval('document_citation_taxon_concepts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citations ALTER COLUMN id SET DEFAULT nextval('document_citations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_tags ALTER COLUMN id SET DEFAULT nextval('document_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decision_confirmations ALTER COLUMN id SET DEFAULT nextval('eu_decision_confirmations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decision_types ALTER COLUMN id SET DEFAULT nextval('eu_decision_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions ALTER COLUMN id SET DEFAULT nextval('eu_decisions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_entities ALTER COLUMN id SET DEFAULT nextval('geo_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_entity_types ALTER COLUMN id SET DEFAULT nextval('geo_entity_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationship_types ALTER COLUMN id SET DEFAULT nextval('geo_relationship_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationships ALTER COLUMN id SET DEFAULT nextval('geo_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments ALTER COLUMN id SET DEFAULT nextval('instruments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY iucn_mappings ALTER COLUMN id SET DEFAULT nextval('iucn_mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY languages ALTER COLUMN id SET DEFAULT nextval('languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes ALTER COLUMN id SET DEFAULT nextval('listing_changes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_distributions ALTER COLUMN id SET DEFAULT nextval('listing_distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY preset_tags ALTER COLUMN id SET DEFAULT nextval('preset_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposal_details ALTER COLUMN id SET DEFAULT nextval('proposal_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ranks ALTER COLUMN id SET DEFAULT nextval('ranks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "references" ALTER COLUMN id SET DEFAULT nextval('references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY references_legacy_id_mapping ALTER COLUMN id SET DEFAULT nextval('references_legacy_id_mapping_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY review_details ALTER COLUMN id SET DEFAULT nextval('review_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY species_listings ALTER COLUMN id SET DEFAULT nextval('species_listings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_commons ALTER COLUMN id SET DEFAULT nextval('taxon_commons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_references ALTER COLUMN id SET DEFAULT nextval('taxon_concept_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts ALTER COLUMN id SET DEFAULT nextval('taxon_concepts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_instruments ALTER COLUMN id SET DEFAULT nextval('taxon_instruments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_names ALTER COLUMN id SET DEFAULT nextval('taxon_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationship_types ALTER COLUMN id SET DEFAULT nextval('taxon_relationship_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationships ALTER COLUMN id SET DEFAULT nextval('taxon_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxonomies ALTER COLUMN id SET DEFAULT nextval('taxonomies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY term_trade_codes_pairs ALTER COLUMN id SET DEFAULT nextval('term_trade_codes_pairs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_annual_report_uploads ALTER COLUMN id SET DEFAULT nextval('trade_annual_report_uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_codes ALTER COLUMN id SET DEFAULT nextval('trade_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_permits ALTER COLUMN id SET DEFAULT nextval('trade_permits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_purposes ALTER COLUMN id SET DEFAULT nextval('trade_restriction_purposes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_sources ALTER COLUMN id SET DEFAULT nextval('trade_restriction_sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_terms ALTER COLUMN id SET DEFAULT nextval('trade_restriction_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restrictions ALTER COLUMN id SET DEFAULT nextval('trade_restrictions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_sandbox_template ALTER COLUMN id SET DEFAULT nextval('trade_sandbox_template_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments ALTER COLUMN id SET DEFAULT nextval('trade_shipments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_taxon_concept_term_pairs ALTER COLUMN id SET DEFAULT nextval('trade_taxon_concept_term_pairs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_trade_data_downloads ALTER COLUMN id SET DEFAULT nextval('trade_trade_data_downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_validation_rules ALTER COLUMN id SET DEFAULT nextval('trade_validation_rules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: admin_iucn_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY iucn_mappings
    ADD CONSTRAINT admin_iucn_mappings_pkey PRIMARY KEY (id);


--
-- Name: ahoy_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ahoy_events
    ADD CONSTRAINT ahoy_events_pkey PRIMARY KEY (id);


--
-- Name: ahoy_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ahoy_visits
    ADD CONSTRAINT ahoy_visits_pkey PRIMARY KEY (id);


--
-- Name: annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_pkey PRIMARY KEY (id);


--
-- Name: change_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY change_types
    ADD CONSTRAINT change_types_pkey PRIMARY KEY (id);


--
-- Name: cites_suspension_confirmations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cites_suspension_confirmations
    ADD CONSTRAINT cites_suspension_confirmations_pkey PRIMARY KEY (id);


--
-- Name: cms_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cms_mappings
    ADD CONSTRAINT cms_mappings_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: common_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY common_names
    ADD CONSTRAINT common_names_pkey PRIMARY KEY (id);


--
-- Name: designation_geo_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY designation_geo_entities
    ADD CONSTRAINT designation_geo_entities_pkey PRIMARY KEY (id);


--
-- Name: designations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY designations
    ADD CONSTRAINT designations_pkey PRIMARY KEY (id);


--
-- Name: distribution_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY distribution_references
    ADD CONSTRAINT distribution_references_pkey PRIMARY KEY (id);


--
-- Name: distributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_pkey PRIMARY KEY (id);


--
-- Name: document_citation_geo_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY document_citation_geo_entities
    ADD CONSTRAINT document_citation_geo_entities_pkey PRIMARY KEY (id);


--
-- Name: document_citation_taxon_concepts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY document_citation_taxon_concepts
    ADD CONSTRAINT document_citation_taxon_concepts_pkey PRIMARY KEY (id);


--
-- Name: document_citations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY document_citations
    ADD CONSTRAINT document_citations_pkey PRIMARY KEY (id);


--
-- Name: document_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY document_tags
    ADD CONSTRAINT document_tags_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: eu_decision_confirmations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eu_decision_confirmations
    ADD CONSTRAINT eu_decision_confirmations_pkey PRIMARY KEY (id);


--
-- Name: eu_decision_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eu_decision_types
    ADD CONSTRAINT eu_decision_types_pkey PRIMARY KEY (id);


--
-- Name: eu_decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: geo_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geo_entities
    ADD CONSTRAINT geo_entities_pkey PRIMARY KEY (id);


--
-- Name: geo_entity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geo_entity_types
    ADD CONSTRAINT geo_entity_types_pkey PRIMARY KEY (id);


--
-- Name: geo_relationship_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geo_relationship_types
    ADD CONSTRAINT geo_relationship_types_pkey PRIMARY KEY (id);


--
-- Name: geo_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geo_relationships
    ADD CONSTRAINT geo_relationships_pkey PRIMARY KEY (id);


--
-- Name: instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instruments
    ADD CONSTRAINT instruments_pkey PRIMARY KEY (id);


--
-- Name: languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: listing_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_pkey PRIMARY KEY (id);


--
-- Name: listing_distributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listing_distributions
    ADD CONSTRAINT listing_distributions_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: preset_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preset_tags
    ADD CONSTRAINT preset_tags_pkey PRIMARY KEY (id);


--
-- Name: proposal_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY proposal_details
    ADD CONSTRAINT proposal_details_pkey PRIMARY KEY (id);


--
-- Name: ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (id);


--
-- Name: references_legacy_id_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY references_legacy_id_mapping
    ADD CONSTRAINT references_legacy_id_mapping_pkey PRIMARY KEY (id);


--
-- Name: references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "references"
    ADD CONSTRAINT references_pkey PRIMARY KEY (id);


--
-- Name: review_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY review_details
    ADD CONSTRAINT review_details_pkey PRIMARY KEY (id);


--
-- Name: species_listings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY species_listings
    ADD CONSTRAINT species_listings_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: taxon_commons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_commons
    ADD CONSTRAINT taxon_commons_pkey PRIMARY KEY (id);


--
-- Name: taxon_concept_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_concept_references
    ADD CONSTRAINT taxon_concept_references_pkey PRIMARY KEY (id);


--
-- Name: taxon_concepts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_pkey PRIMARY KEY (id);


--
-- Name: taxon_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_instruments
    ADD CONSTRAINT taxon_instruments_pkey PRIMARY KEY (id);


--
-- Name: taxon_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_names
    ADD CONSTRAINT taxon_names_pkey PRIMARY KEY (id);


--
-- Name: taxon_relationship_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_relationship_types
    ADD CONSTRAINT taxon_relationship_types_pkey PRIMARY KEY (id);


--
-- Name: taxon_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_relationships
    ADD CONSTRAINT taxon_relationships_pkey PRIMARY KEY (id);


--
-- Name: taxonomies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxonomies
    ADD CONSTRAINT taxonomies_pkey PRIMARY KEY (id);


--
-- Name: term_trade_codes_pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY term_trade_codes_pairs
    ADD CONSTRAINT term_trade_codes_pairs_pkey PRIMARY KEY (id);


--
-- Name: trade_annual_report_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_annual_report_uploads
    ADD CONSTRAINT trade_annual_report_uploads_pkey PRIMARY KEY (id);


--
-- Name: trade_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_codes
    ADD CONSTRAINT trade_codes_pkey PRIMARY KEY (id);


--
-- Name: trade_permits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_permits
    ADD CONSTRAINT trade_permits_pkey PRIMARY KEY (id);


--
-- Name: trade_restriction_purposes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_restriction_purposes
    ADD CONSTRAINT trade_restriction_purposes_pkey PRIMARY KEY (id);


--
-- Name: trade_restriction_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_restriction_sources
    ADD CONSTRAINT trade_restriction_sources_pkey PRIMARY KEY (id);


--
-- Name: trade_restriction_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_restriction_terms
    ADD CONSTRAINT trade_restriction_terms_pkey PRIMARY KEY (id);


--
-- Name: trade_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_restrictions
    ADD CONSTRAINT trade_restrictions_pkey PRIMARY KEY (id);


--
-- Name: trade_sandbox_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_sandbox_template
    ADD CONSTRAINT trade_sandbox_template_pkey PRIMARY KEY (id);


--
-- Name: trade_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_pkey PRIMARY KEY (id);


--
-- Name: trade_taxon_concept_code_pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_taxon_concept_term_pairs
    ADD CONSTRAINT trade_taxon_concept_code_pairs_pkey PRIMARY KEY (id);


--
-- Name: trade_trade_data_downloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_trade_data_downloads
    ADD CONSTRAINT trade_trade_data_downloads_pkey PRIMARY KEY (id);


--
-- Name: trade_validation_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_validation_rules
    ADD CONSTRAINT trade_validation_rules_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx3; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx3 ON auto_complete_taxon_concepts_mview USING btree (name_for_matching text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_species_plus_ac);


--
-- Name: auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx4; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx4 ON auto_complete_taxon_concepts_mview USING btree (name_for_matching text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_checklist_ac);


--
-- Name: auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx5; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx5 ON auto_complete_taxon_concepts_mview USING btree (name_for_matching text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_trade_ac);


--
-- Name: auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx6; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx6 ON auto_complete_taxon_concepts_mview USING btree (name_for_matching text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_trade_internal_ac);


--
-- Name: cites_species_listing_mview_tmp_countries_ids_ary_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX cites_species_listing_mview_tmp_countries_ids_ary_idx ON cites_species_listing_mview USING gin (countries_ids_ary);


--
-- Name: cms_species_listing_mview_tmp_countries_ids_ary_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX cms_species_listing_mview_tmp_countries_ids_ary_idx ON cms_species_listing_mview USING gin (countries_ids_ary);


--
-- Name: eu_species_listing_mview_tmp_countries_ids_ary_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX eu_species_listing_mview_tmp_countries_ids_ary_idx ON eu_species_listing_mview USING gin (countries_ids_ary);


--
-- Name: index_ahoy_events_on_time; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ahoy_events_on_time ON ahoy_events USING btree ("time");


--
-- Name: index_ahoy_events_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ahoy_events_on_user_id ON ahoy_events USING btree (user_id);


--
-- Name: index_ahoy_events_on_visit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ahoy_events_on_visit_id ON ahoy_events USING btree (visit_id);


--
-- Name: index_ahoy_visits_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ahoy_visits_on_user_id ON ahoy_visits USING btree (user_id);


--
-- Name: index_comments_on_commentable_and_comment_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_and_comment_type ON comments USING btree (commentable_id, commentable_type, comment_type);


--
-- Name: index_distribution_references_on_distribution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_distribution_references_on_distribution_id ON distribution_references USING btree (distribution_id);


--
-- Name: index_distribution_references_on_reference_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_distribution_references_on_reference_id ON distribution_references USING btree (reference_id);


--
-- Name: index_distribution_refs_on_distribution_id_reference_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_distribution_refs_on_distribution_id_reference_id ON distribution_references USING btree (distribution_id, reference_id);


--
-- Name: index_distributions_on_taxon_concept_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_distributions_on_taxon_concept_id ON distributions USING btree (taxon_concept_id);


--
-- Name: index_document_tags_documents_composite; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_document_tags_documents_composite ON document_tags_documents USING btree (document_id, document_tag_id);


--
-- Name: index_document_tags_documents_on_document_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_document_tags_documents_on_document_tag_id ON document_tags_documents USING btree (document_tag_id);


--
-- Name: index_documents_on_title_to_ts_vector; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_documents_on_title_to_ts_vector ON documents USING gin (to_tsvector('simple'::regconfig, COALESCE(title, ''::text)));


--
-- Name: index_listing_changes_on_annotation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_annotation_id ON listing_changes USING btree (annotation_id);


--
-- Name: index_listing_changes_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_event_id ON listing_changes USING btree (event_id);


--
-- Name: index_listing_changes_on_hash_annotation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_hash_annotation_id ON listing_changes USING btree (hash_annotation_id);


--
-- Name: index_listing_changes_on_inclusion_taxon_concept_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_inclusion_taxon_concept_id ON listing_changes USING btree (inclusion_taxon_concept_id);


--
-- Name: index_listing_changes_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_parent_id ON listing_changes USING btree (parent_id);


--
-- Name: index_listing_changes_on_taxon_concept_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_taxon_concept_id ON listing_changes USING btree (taxon_concept_id);


--
-- Name: index_listing_distributions_on_geo_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_distributions_on_geo_entity_id ON listing_distributions USING btree (geo_entity_id);


--
-- Name: index_listing_distributions_on_listing_change_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_distributions_on_listing_change_id ON listing_distributions USING btree (listing_change_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_taxon_concept_references_on_taxon_concept_id_and_ref_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concept_references_on_taxon_concept_id_and_ref_id ON taxon_concept_references USING btree (taxon_concept_id, reference_id);


--
-- Name: index_taxon_concepts_on_full_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_full_name ON taxon_concepts USING btree (upper((full_name)::text) text_pattern_ops);


--
-- Name: index_taxon_concepts_on_legacy_trade_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_legacy_trade_code ON taxon_concepts USING btree (legacy_trade_code);


--
-- Name: index_taxon_concepts_on_name_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_name_status ON taxon_concepts USING btree (name_status);


--
-- Name: index_taxon_concepts_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_parent_id ON taxon_concepts USING btree (parent_id);


--
-- Name: index_taxon_concepts_on_taxonomy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_taxonomy_id ON taxon_concepts USING btree (taxonomy_id);


--
-- Name: index_taxon_instruments_on_taxon_concept_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_instruments_on_taxon_concept_id ON taxon_instruments USING btree (taxon_concept_id);


--
-- Name: index_term_trade_codes_pairs_on_term_and_trade_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_term_trade_codes_pairs_on_term_and_trade_code ON term_trade_codes_pairs USING btree (term_id, trade_code_id, trade_code_type);


--
-- Name: index_trade_shipments_on_appendix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_appendix ON trade_shipments USING btree (appendix);


--
-- Name: index_trade_shipments_on_country_of_origin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_country_of_origin_id ON trade_shipments USING btree (country_of_origin_id);


--
-- Name: index_trade_shipments_on_export_permits_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_export_permits_ids ON trade_shipments USING gin (export_permits_ids);


--
-- Name: index_trade_shipments_on_exporter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_exporter_id ON trade_shipments USING btree (exporter_id);


--
-- Name: index_trade_shipments_on_import_permits_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_import_permits_ids ON trade_shipments USING gin (import_permits_ids);


--
-- Name: index_trade_shipments_on_importer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_importer_id ON trade_shipments USING btree (importer_id);


--
-- Name: index_trade_shipments_on_origin_permits_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_origin_permits_ids ON trade_shipments USING gin (origin_permits_ids);


--
-- Name: index_trade_shipments_on_purpose_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_purpose_id ON trade_shipments USING btree (purpose_id);


--
-- Name: index_trade_shipments_on_quantity; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_quantity ON trade_shipments USING btree (quantity);


--
-- Name: index_trade_shipments_on_reported_taxon_concept_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_reported_taxon_concept_id ON trade_shipments USING btree (reported_taxon_concept_id);


--
-- Name: index_trade_shipments_on_sandbox_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_sandbox_id ON trade_shipments USING btree (sandbox_id);


--
-- Name: index_trade_shipments_on_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_source_id ON trade_shipments USING btree (source_id);


--
-- Name: index_trade_shipments_on_taxon_concept_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_taxon_concept_id ON trade_shipments USING btree (taxon_concept_id);


--
-- Name: index_trade_shipments_on_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_term_id ON trade_shipments USING btree (term_id);


--
-- Name: index_trade_shipments_on_unit_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_unit_id ON trade_shipments USING btree (unit_id);


--
-- Name: index_trade_shipments_on_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_year ON trade_shipments USING btree (year);


--
-- Name: index_trade_shipments_on_year_exporter_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_year_exporter_id ON trade_shipments USING btree (year, exporter_id);


--
-- Name: index_trade_shipments_on_year_importer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trade_shipments_on_year_importer_id ON trade_shipments USING btree (year, importer_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: listing_changes_mview_display_in_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX listing_changes_mview_display_in_index ON listing_changes_mview USING btree (is_current, display_in_index, designation_id);


--
-- Name: listing_changes_mview_tmp_id_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX listing_changes_mview_tmp_id_taxon_concept_id_idx1 ON listing_changes_mview USING btree (id, taxon_concept_id);


--
-- Name: listing_changes_mview_tmp_inclusion_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX listing_changes_mview_tmp_inclusion_taxon_concept_id_idx1 ON listing_changes_mview USING btree (inclusion_taxon_concept_id);


--
-- Name: listing_changes_mview_tmp_is_current_designation_name_chan_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX listing_changes_mview_tmp_is_current_designation_name_chan_idx1 ON listing_changes_mview USING btree (is_current, designation_name, change_type_name);


--
-- Name: listing_changes_mview_tmp_original_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX listing_changes_mview_tmp_original_taxon_concept_id_idx1 ON listing_changes_mview USING btree (original_taxon_concept_id);


--
-- Name: listing_changes_mview_tmp_show_in_downloads_taxon_concept__idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX listing_changes_mview_tmp_show_in_downloads_taxon_concept__idx1 ON listing_changes_mview USING btree (show_in_downloads, taxon_concept_id, designation_id);


--
-- Name: listing_changes_mview_tmp_show_in_timeline_taxon_concept_i_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX listing_changes_mview_tmp_show_in_timeline_taxon_concept_i_idx1 ON listing_changes_mview USING btree (show_in_timeline, taxon_concept_id, designation_id);


--
-- Name: taxon_concepts_mview_tmp_cites_show_name_status_cites_listi_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_tmp_cites_show_name_status_cites_listi_idx ON taxon_concepts_mview USING btree (cites_show, name_status, cites_listing_original, taxonomy_is_cites_eu, rank_name);


--
-- Name: taxon_concepts_mview_tmp_cms_show_name_status_cms_listing_o_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_tmp_cms_show_name_status_cms_listing_o_idx ON taxon_concepts_mview USING btree (cms_show, name_status, cms_listing_original, taxonomy_is_cites_eu, rank_name);


--
-- Name: taxon_concepts_mview_tmp_countries_ids_ary_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_tmp_countries_ids_ary_idx1 ON taxon_concepts_mview USING gin (countries_ids_ary);


--
-- Name: taxon_concepts_mview_tmp_eu_show_name_status_eu_listing_ori_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_tmp_eu_show_name_status_eu_listing_ori_idx ON taxon_concepts_mview USING btree (eu_show, name_status, eu_listing_original, taxonomy_is_cites_eu, rank_name);


--
-- Name: taxon_concepts_mview_tmp_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_tmp_id_idx ON taxon_concepts_mview USING btree (id);


--
-- Name: taxon_concepts_mview_tmp_parent_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_tmp_parent_id_idx ON taxon_concepts_mview USING btree (parent_id);


--
-- Name: taxon_concepts_mview_tmp_taxonomy_is_cites_eu_cites_listed__idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_tmp_taxonomy_is_cites_eu_cites_listed__idx ON taxon_concepts_mview USING btree (taxonomy_is_cites_eu, cites_listed, kingdom_position);


--
-- Name: tmp_cascaded_cites_listing_ch_show_in_downloads_taxon_conc_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cites_listing_ch_show_in_downloads_taxon_conc_idx1 ON cites_listing_changes_mview USING btree (show_in_downloads, taxon_concept_id);


--
-- Name: tmp_cascaded_cites_listing_ch_show_in_timeline_taxon_conce_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cites_listing_ch_show_in_timeline_taxon_conce_idx1 ON cites_listing_changes_mview USING btree (show_in_timeline, taxon_concept_id);


--
-- Name: tmp_cascaded_cites_listing_ch_taxon_concept_id_original_ta_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cites_listing_ch_taxon_concept_id_original_ta_idx1 ON cites_listing_changes_mview USING btree (taxon_concept_id, original_taxon_concept_id, change_type_id, effective_at);


--
-- Name: tmp_cascaded_cites_listing_cha_is_current_change_type_name_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cites_listing_cha_is_current_change_type_name_idx1 ON cites_listing_changes_mview USING btree (is_current, change_type_name);


--
-- Name: tmp_cascaded_cites_listing_chan_inclusion_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cites_listing_chan_inclusion_taxon_concept_id_idx1 ON cites_listing_changes_mview USING btree (inclusion_taxon_concept_id);


--
-- Name: tmp_cascaded_cites_listing_chang_excluded_geo_entities_ids_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cites_listing_chang_excluded_geo_entities_ids_idx1 ON cites_listing_changes_mview USING gin (excluded_geo_entities_ids);


--
-- Name: tmp_cascaded_cites_listing_chang_original_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cites_listing_chang_original_taxon_concept_id_idx1 ON cites_listing_changes_mview USING btree (original_taxon_concept_id);


--
-- Name: tmp_cascaded_cites_listing_changes_listed_geo_entities_ids_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cites_listing_changes_listed_geo_entities_ids_idx1 ON cites_listing_changes_mview USING gin (listed_geo_entities_ids);


--
-- Name: tmp_cascaded_cites_listing_changes_mvi_id_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cites_listing_changes_mvi_id_taxon_concept_id_idx1 ON cites_listing_changes_mview USING btree (id, taxon_concept_id);


--
-- Name: tmp_cascaded_cms_listing_chan_show_in_downloads_taxon_conc_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cms_listing_chan_show_in_downloads_taxon_conc_idx1 ON cms_listing_changes_mview USING btree (show_in_downloads, taxon_concept_id);


--
-- Name: tmp_cascaded_cms_listing_chan_show_in_timeline_taxon_conce_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cms_listing_chan_show_in_timeline_taxon_conce_idx1 ON cms_listing_changes_mview USING btree (show_in_timeline, taxon_concept_id);


--
-- Name: tmp_cascaded_cms_listing_chan_taxon_concept_id_original_ta_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cms_listing_chan_taxon_concept_id_original_ta_idx1 ON cms_listing_changes_mview USING btree (taxon_concept_id, original_taxon_concept_id, change_type_id, effective_at);


--
-- Name: tmp_cascaded_cms_listing_chang_is_current_change_type_name_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cms_listing_chang_is_current_change_type_name_idx1 ON cms_listing_changes_mview USING btree (is_current, change_type_name);


--
-- Name: tmp_cascaded_cms_listing_change_inclusion_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cms_listing_change_inclusion_taxon_concept_id_idx1 ON cms_listing_changes_mview USING btree (inclusion_taxon_concept_id);


--
-- Name: tmp_cascaded_cms_listing_changes_excluded_geo_entities_ids_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cms_listing_changes_excluded_geo_entities_ids_idx1 ON cms_listing_changes_mview USING gin (excluded_geo_entities_ids);


--
-- Name: tmp_cascaded_cms_listing_changes_m_listed_geo_entities_ids_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cms_listing_changes_m_listed_geo_entities_ids_idx1 ON cms_listing_changes_mview USING gin (listed_geo_entities_ids);


--
-- Name: tmp_cascaded_cms_listing_changes_mview_id_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cms_listing_changes_mview_id_taxon_concept_id_idx1 ON cms_listing_changes_mview USING btree (id, taxon_concept_id);


--
-- Name: tmp_cascaded_cms_listing_changes_original_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_cms_listing_changes_original_taxon_concept_id_idx1 ON cms_listing_changes_mview USING btree (original_taxon_concept_id);


--
-- Name: tmp_cascaded_eu_listing_chang_show_in_downloads_taxon_conc_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_eu_listing_chang_show_in_downloads_taxon_conc_idx1 ON eu_listing_changes_mview USING btree (show_in_downloads, taxon_concept_id);


--
-- Name: tmp_cascaded_eu_listing_chang_show_in_timeline_taxon_conce_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_eu_listing_chang_show_in_timeline_taxon_conce_idx1 ON eu_listing_changes_mview USING btree (show_in_timeline, taxon_concept_id);


--
-- Name: tmp_cascaded_eu_listing_chang_taxon_concept_id_original_ta_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_eu_listing_chang_taxon_concept_id_original_ta_idx1 ON eu_listing_changes_mview USING btree (taxon_concept_id, original_taxon_concept_id, change_type_id, effective_at);


--
-- Name: tmp_cascaded_eu_listing_change_is_current_change_type_name_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_eu_listing_change_is_current_change_type_name_idx1 ON eu_listing_changes_mview USING btree (is_current, change_type_name);


--
-- Name: tmp_cascaded_eu_listing_changes__excluded_geo_entities_ids_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_eu_listing_changes__excluded_geo_entities_ids_idx1 ON eu_listing_changes_mview USING gin (excluded_geo_entities_ids);


--
-- Name: tmp_cascaded_eu_listing_changes__original_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_eu_listing_changes__original_taxon_concept_id_idx1 ON eu_listing_changes_mview USING btree (original_taxon_concept_id);


--
-- Name: tmp_cascaded_eu_listing_changes_inclusion_taxon_concept_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_eu_listing_changes_inclusion_taxon_concept_id_idx1 ON eu_listing_changes_mview USING btree (inclusion_taxon_concept_id);


--
-- Name: tmp_cascaded_eu_listing_changes_mv_listed_geo_entities_ids_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_cascaded_eu_listing_changes_mv_listed_geo_entities_ids_idx1 ON eu_listing_changes_mview USING gin (listed_geo_entities_ids);


--
-- Name: tmp_valid_taxon_concept_annex_taxon_concept_id_annex_effec_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX tmp_valid_taxon_concept_annex_taxon_concept_id_annex_effec_idx1 ON valid_taxon_concept_annex_year_mview USING btree (taxon_concept_id, annex, effective_from, effective_to);


--
-- Name: trade_permits_number_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX trade_permits_number_idx ON trade_permits USING btree (number);


--
-- Name: trade_restrictions_extract_year_from_start_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX trade_restrictions_extract_year_from_start_date ON trade_restrictions USING btree (date_part('year'::text, start_date)) WHERE ((type)::text = 'Quota'::text);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: valid_taxon_concept_annex_year_mview_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX valid_taxon_concept_annex_year_mview_idx ON valid_taxon_concept_annex_year_mview USING btree (taxon_concept_id, effective_from, effective_to, annex);


--
-- Name: valid_taxon_concept_appendix_year_mview_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX valid_taxon_concept_appendix_year_mview_idx ON valid_taxon_concept_appendix_year_mview USING btree (taxon_concept_id, effective_from, effective_to, appendix);


--
-- Name: valid_taxon_concept_appendix_year_mview_year_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX valid_taxon_concept_appendix_year_mview_year_idx ON valid_taxon_concept_appendix_year_mview USING btree (taxon_concept_id, date_part('year'::text, effective_from), date_part('year'::text, effective_to), appendix);


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO documents_view DO INSTEAD  SELECT d.id,
    d.title,
    d.filename,
    d.date,
    d.type,
    d.is_public,
    d.event_id,
    d.language_id,
    d.legacy_id,
    d.created_by_id,
    d.updated_by_id,
    d.created_at,
    d.updated_at,
    d.number,
    e.type AS event_type,
    array_agg_notnull(dctc.taxon_concept_id) AS taxon_concept_ids,
    array_agg(dcge.geo_entity_id) AS geo_entity_ids,
    (array_agg(po.id) || array_agg(rp.id)) AS document_tags_ids
   FROM ((((((((documents d
     LEFT JOIN events e ON ((e.id = d.event_id)))
     LEFT JOIN document_citations dc ON ((dc.document_id = d.id)))
     LEFT JOIN document_citation_taxon_concepts dctc ON ((dctc.document_citation_id = dc.id)))
     LEFT JOIN document_citation_geo_entities dcge ON ((dcge.document_citation_id = dc.id)))
     LEFT JOIN proposal_details pd ON ((pd.document_id = d.id)))
     LEFT JOIN document_tags po ON ((pd.proposal_outcome_id = po.id)))
     LEFT JOIN review_details rd ON ((rd.document_id = d.id)))
     LEFT JOIN document_tags rp ON ((rd.review_phase_id = rp.id)))
  GROUP BY d.id, e.type;


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO taxon_concepts_distributions_view DO INSTEAD  SELECT taxon_concepts.id,
    taxon_concepts.legacy_id,
    (taxon_concepts.data -> 'phylum_name'::text) AS phylum_name,
    (taxon_concepts.data -> 'class_name'::text) AS class_name,
    (taxon_concepts.data -> 'order_name'::text) AS order_name,
    (taxon_concepts.data -> 'family_name'::text) AS family_name,
    taxon_concepts.full_name,
    (taxon_concepts.data -> 'rank_name'::text) AS rank_name,
    geo_entity_types.name AS geo_entity_type,
    geo_entities.name_en AS geo_entity_name,
    geo_entities.iso_code2 AS geo_entity_iso_code2,
    string_agg((tags.name)::text, ', '::text) AS tags,
    "references".citation AS reference_full,
    "references".id AS reference_id,
    "references".legacy_id AS reference_legacy_id,
    taxonomies.name AS taxonomy_name,
    taxon_concepts.taxonomic_position,
    taxon_concepts.taxonomy_id,
    array_to_string(ARRAY[distribution_note.note, distributions.internal_notes], '
'::text) AS internal_notes,
    to_char(distributions.created_at, 'DD/MM/YYYY'::text) AS created_at,
    uc.name AS created_by,
    to_char(distributions.updated_at, 'DD/MM/YYYY'::text) AS updated_at,
    uu.name AS updated_by
   FROM (((((((((((distributions
     RIGHT JOIN taxon_concepts ON ((distributions.taxon_concept_id = taxon_concepts.id)))
     LEFT JOIN taxonomies ON ((taxonomies.id = taxon_concepts.taxonomy_id)))
     LEFT JOIN geo_entities ON ((geo_entities.id = distributions.geo_entity_id)))
     LEFT JOIN geo_entity_types ON ((geo_entity_types.id = geo_entities.geo_entity_type_id)))
     LEFT JOIN distribution_references ON ((distribution_references.distribution_id = distributions.id)))
     LEFT JOIN "references" ON (("references".id = distribution_references.reference_id)))
     LEFT JOIN taggings ON (((taggings.taggable_id = distributions.id) AND ((taggings.taggable_type)::text = 'Distribution'::text))))
     LEFT JOIN tags ON ((tags.id = taggings.tag_id)))
     LEFT JOIN comments distribution_note ON ((((distribution_note.commentable_id = taxon_concepts.id) AND ((distribution_note.commentable_type)::text = 'TaxonConcept'::text)) AND ((distribution_note.comment_type)::text = 'Distribution'::text))))
     LEFT JOIN users uc ON ((distributions.created_by_id = uc.id)))
     LEFT JOIN users uu ON ((distributions.updated_by_id = uu.id)))
  WHERE ((taxon_concepts.name_status)::text = 'A'::text)
  GROUP BY taxon_concepts.id, taxon_concepts.legacy_id, geo_entity_types.name, geo_entities.name_en, geo_entities.iso_code2, "references".citation, "references".id, taxonomies.name, distributions.internal_notes, distribution_note.note, uc.name, uu.name, distributions.created_at, distributions.updated_at;


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO api_taxon_concepts_view DO INSTEAD  SELECT tc.id,
    tc.parent_id,
    taxonomies.name,
        CASE
            WHEN ((taxonomies.name)::text = 'CITES'::text) THEN true
            ELSE false
        END AS taxonomy_is_cites_eu,
    tc.full_name,
    tc.author_year,
    'A'::text AS name_status,
    ranks.name AS rank,
    tc.taxonomic_position,
    row_to_json(ROW((tc.data -> 'kingdom_name'::text), (tc.data -> 'phylum_name'::text), (tc.data -> 'class_name'::text), (tc.data -> 'order_name'::text), (tc.data -> 'family_name'::text))::higher_taxa) AS higher_taxa,
    array_to_json(array_agg_notnull(ROW(synonyms.id, (synonyms.full_name)::text, (synonyms.author_year)::text)::simple_taxon_concept)) AS synonyms,
    NULL::json AS accepted_names,
    tc.created_at,
    tc.updated_at
   FROM (((((taxon_concepts tc
     JOIN taxonomies ON ((taxonomies.id = tc.taxonomy_id)))
     JOIN ranks ON ((ranks.id = tc.rank_id)))
     LEFT JOIN taxon_relationships tr ON ((tr.taxon_concept_id = tc.id)))
     LEFT JOIN taxon_relationship_types trt ON (((trt.id = tr.taxon_relationship_type_id) AND ((trt.name)::text = 'HAS_SYNONYM'::text))))
     LEFT JOIN taxon_concepts_mview synonyms ON ((synonyms.id = tr.other_taxon_concept_id)))
  WHERE ((tc.name_status)::text = 'A'::text)
  GROUP BY tc.id, tc.parent_id, taxonomies.name, tc.full_name, tc.author_year, ranks.name, tc.taxonomic_position, tc.created_at, tc.updated_at
UNION ALL
 SELECT tc.id,
    NULL::integer AS parent_id,
    taxonomies.name,
        CASE
            WHEN ((taxonomies.name)::text = 'CITES'::text) THEN true
            ELSE false
        END AS taxonomy_is_cites_eu,
    tc.full_name,
    tc.author_year,
    'S'::text AS name_status,
    ranks.name AS rank,
    NULL::character varying AS taxonomic_position,
    NULL::json AS higher_taxa,
    NULL::json AS synonyms,
    array_to_json(array_agg_notnull(ROW(accepted_names.id, (accepted_names.full_name)::text, (accepted_names.author_year)::text)::simple_taxon_concept)) AS accepted_names,
    tc.created_at,
    tc.updated_at
   FROM (((((taxon_concepts tc
     JOIN taxonomies ON ((taxonomies.id = tc.taxonomy_id)))
     JOIN ranks ON ((ranks.id = tc.rank_id)))
     JOIN taxon_relationships tr ON ((tr.other_taxon_concept_id = tc.id)))
     JOIN taxon_relationship_types trt ON (((trt.id = tr.taxon_relationship_type_id) AND ((trt.name)::text = 'HAS_SYNONYM'::text))))
     JOIN taxon_concepts_mview accepted_names ON ((accepted_names.id = tr.taxon_concept_id)))
  WHERE ((tc.name_status)::text = 'S'::text)
  GROUP BY tc.id, tc.parent_id, taxonomies.name, tc.full_name, tc.author_year, ranks.name, tc.taxonomic_position, tc.created_at, tc.updated_at;


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO api_distributions_view DO INSTEAD  SELECT d.id,
    d.taxon_concept_id,
    g.name_en,
    g.name_es,
    g.name_fr,
    g.iso_code2,
    gt.name AS geo_entity_type,
    array_agg_notnull(tags.name ORDER BY tags.name) AS tags,
    array_agg_notnull(r.citation ORDER BY r.citation) AS citations,
    d.created_at,
    d.updated_at
   FROM ((((((distributions d
     JOIN geo_entities g ON ((g.id = d.geo_entity_id)))
     JOIN geo_entity_types gt ON ((gt.id = g.geo_entity_type_id)))
     LEFT JOIN taggings ON ((((taggings.taggable_type)::text = 'Distribution'::text) AND (taggings.taggable_id = d.id))))
     LEFT JOIN tags ON ((tags.id = taggings.tag_id)))
     LEFT JOIN distribution_references dr ON ((dr.distribution_id = d.id)))
     LEFT JOIN "references" r ON ((r.id = dr.reference_id)))
  GROUP BY d.id, g.name_en, g.name_es, g.name_fr, g.iso_code2, gt.name;


--
-- Name: ahoy_events_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ahoy_events
    ADD CONSTRAINT ahoy_events_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: ahoy_visits_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ahoy_visits
    ADD CONSTRAINT ahoy_visits_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: annotations_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: annotations_event_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_event_id_fk FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: annotations_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_source_id_fk FOREIGN KEY (original_id) REFERENCES annotations(id);


--
-- Name: annotations_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: change_types_designation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY change_types
    ADD CONSTRAINT change_types_designation_id_fk FOREIGN KEY (designation_id) REFERENCES designations(id);


--
-- Name: cites_suspension_confirmations_cites_suspension_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cites_suspension_confirmations
    ADD CONSTRAINT cites_suspension_confirmations_cites_suspension_id_fk FOREIGN KEY (cites_suspension_id) REFERENCES trade_restrictions(id);


--
-- Name: cites_suspension_confirmations_notification_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cites_suspension_confirmations
    ADD CONSTRAINT cites_suspension_confirmations_notification_id_fk FOREIGN KEY (cites_suspension_notification_id) REFERENCES events(id);


--
-- Name: comments_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: comments_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: common_names_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY common_names
    ADD CONSTRAINT common_names_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: common_names_language_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY common_names
    ADD CONSTRAINT common_names_language_id_fk FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: common_names_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY common_names
    ADD CONSTRAINT common_names_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: designation_geo_entities_designation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY designation_geo_entities
    ADD CONSTRAINT designation_geo_entities_designation_id_fk FOREIGN KEY (designation_id) REFERENCES designations(id);


--
-- Name: designation_geo_entities_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY designation_geo_entities
    ADD CONSTRAINT designation_geo_entities_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: designations_taxonomy_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY designations
    ADD CONSTRAINT designations_taxonomy_id_fk FOREIGN KEY (taxonomy_id) REFERENCES taxonomies(id);


--
-- Name: distribution_references_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distribution_references
    ADD CONSTRAINT distribution_references_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: distribution_references_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distribution_references
    ADD CONSTRAINT distribution_references_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: distributions_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: distributions_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: document_citation_geo_entities_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_geo_entities
    ADD CONSTRAINT document_citation_geo_entities_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: document_citation_geo_entities_document_citation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_geo_entities
    ADD CONSTRAINT document_citation_geo_entities_document_citation_id_fk FOREIGN KEY (document_citation_id) REFERENCES document_citations(id);


--
-- Name: document_citation_geo_entities_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_geo_entities
    ADD CONSTRAINT document_citation_geo_entities_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: document_citation_geo_entities_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_geo_entities
    ADD CONSTRAINT document_citation_geo_entities_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: document_citation_taxon_concepts_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_taxon_concepts
    ADD CONSTRAINT document_citation_taxon_concepts_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: document_citation_taxon_concepts_document_citation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_taxon_concepts
    ADD CONSTRAINT document_citation_taxon_concepts_document_citation_id_fk FOREIGN KEY (document_citation_id) REFERENCES document_citations(id);


--
-- Name: document_citation_taxon_concepts_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_taxon_concepts
    ADD CONSTRAINT document_citation_taxon_concepts_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: document_citation_taxon_concepts_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citation_taxon_concepts
    ADD CONSTRAINT document_citation_taxon_concepts_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: document_citations_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citations
    ADD CONSTRAINT document_citations_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: document_citations_document_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citations
    ADD CONSTRAINT document_citations_document_id_fk FOREIGN KEY (document_id) REFERENCES documents(id);


--
-- Name: document_citations_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_citations
    ADD CONSTRAINT document_citations_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: documents_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: documents_event_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_event_id_fk FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: documents_language_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_language_id_fk FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: documents_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: eu_decision_confirmations_eu_decision_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decision_confirmations
    ADD CONSTRAINT eu_decision_confirmations_eu_decision_id_fk FOREIGN KEY (eu_decision_id) REFERENCES eu_decisions(id);


--
-- Name: eu_decision_confirmations_event_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decision_confirmations
    ADD CONSTRAINT eu_decision_confirmations_event_id_fk FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: eu_decisions_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: eu_decisions_end_event_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_end_event_id_fk FOREIGN KEY (end_event_id) REFERENCES events(id);


--
-- Name: eu_decisions_eu_decision_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_eu_decision_type_id_fk FOREIGN KEY (eu_decision_type_id) REFERENCES eu_decision_types(id);


--
-- Name: eu_decisions_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: eu_decisions_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_source_id_fk FOREIGN KEY (source_id) REFERENCES trade_codes(id);


--
-- Name: eu_decisions_start_event_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_start_event_id_fk FOREIGN KEY (start_event_id) REFERENCES events(id);


--
-- Name: eu_decisions_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: eu_decisions_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_term_id_fk FOREIGN KEY (term_id) REFERENCES trade_codes(id);


--
-- Name: eu_decisions_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eu_decisions
    ADD CONSTRAINT eu_decisions_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: events_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: events_designation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_designation_id_fk FOREIGN KEY (designation_id) REFERENCES designations(id);


--
-- Name: events_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: geo_entities_geo_entity_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_entities
    ADD CONSTRAINT geo_entities_geo_entity_type_id_fk FOREIGN KEY (geo_entity_type_id) REFERENCES geo_entity_types(id);


--
-- Name: geo_relationships_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationships
    ADD CONSTRAINT geo_relationships_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: geo_relationships_geo_relationship_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationships
    ADD CONSTRAINT geo_relationships_geo_relationship_type_id_fk FOREIGN KEY (geo_relationship_type_id) REFERENCES geo_relationship_types(id);


--
-- Name: geo_relationships_other_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationships
    ADD CONSTRAINT geo_relationships_other_geo_entity_id_fk FOREIGN KEY (other_geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: instruments_designation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments
    ADD CONSTRAINT instruments_designation_id_fk FOREIGN KEY (designation_id) REFERENCES designations(id);


--
-- Name: listing_changes_annotation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_annotation_id_fk FOREIGN KEY (annotation_id) REFERENCES annotations(id);


--
-- Name: listing_changes_change_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_change_type_id_fk FOREIGN KEY (change_type_id) REFERENCES change_types(id);


--
-- Name: listing_changes_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: listing_changes_event_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_event_id_fk FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: listing_changes_hash_annotation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_hash_annotation_id_fk FOREIGN KEY (hash_annotation_id) REFERENCES annotations(id);


--
-- Name: listing_changes_inclusion_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_inclusion_taxon_concept_id_fk FOREIGN KEY (inclusion_taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: listing_changes_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_parent_id_fk FOREIGN KEY (parent_id) REFERENCES listing_changes(id);


--
-- Name: listing_changes_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_source_id_fk FOREIGN KEY (original_id) REFERENCES listing_changes(id);


--
-- Name: listing_changes_species_listing_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_species_listing_id_fk FOREIGN KEY (species_listing_id) REFERENCES species_listings(id);


--
-- Name: listing_changes_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: listing_changes_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: listing_distributions_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_distributions
    ADD CONSTRAINT listing_distributions_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: listing_distributions_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_distributions
    ADD CONSTRAINT listing_distributions_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: listing_distributions_listing_change_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_distributions
    ADD CONSTRAINT listing_distributions_listing_change_id_fk FOREIGN KEY (listing_change_id) REFERENCES listing_changes(id);


--
-- Name: listing_distributions_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_distributions
    ADD CONSTRAINT listing_distributions_source_id_fk FOREIGN KEY (original_id) REFERENCES listing_distributions(id);


--
-- Name: listing_distributions_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_distributions
    ADD CONSTRAINT listing_distributions_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: proposal_details_document_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposal_details
    ADD CONSTRAINT proposal_details_document_id_fk FOREIGN KEY (document_id) REFERENCES documents(id);


--
-- Name: proposal_details_proposal_outcome_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY proposal_details
    ADD CONSTRAINT proposal_details_proposal_outcome_id_fk FOREIGN KEY (proposal_outcome_id) REFERENCES document_tags(id);


--
-- Name: references_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "references"
    ADD CONSTRAINT references_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: references_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "references"
    ADD CONSTRAINT references_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: review_details_document_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY review_details
    ADD CONSTRAINT review_details_document_id_fk FOREIGN KEY (document_id) REFERENCES documents(id);


--
-- Name: review_details_process_stage_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY review_details
    ADD CONSTRAINT review_details_process_stage_id_fk FOREIGN KEY (process_stage_id) REFERENCES document_tags(id);


--
-- Name: review_details_recommended_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY review_details
    ADD CONSTRAINT review_details_recommended_category_id_fk FOREIGN KEY (recommended_category_id) REFERENCES document_tags(id);


--
-- Name: review_details_review_phase_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY review_details
    ADD CONSTRAINT review_details_review_phase_id_fk FOREIGN KEY (review_phase_id) REFERENCES document_tags(id);


--
-- Name: species_listings_designation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY species_listings
    ADD CONSTRAINT species_listings_designation_id_fk FOREIGN KEY (designation_id) REFERENCES designations(id);


--
-- Name: taxon_commons_common_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_commons
    ADD CONSTRAINT taxon_commons_common_name_id_fk FOREIGN KEY (common_name_id) REFERENCES common_names(id);


--
-- Name: taxon_commons_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_commons
    ADD CONSTRAINT taxon_commons_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: taxon_commons_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_commons
    ADD CONSTRAINT taxon_commons_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_commons_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_commons
    ADD CONSTRAINT taxon_commons_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: taxon_concept_geo_entities_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT taxon_concept_geo_entities_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: taxon_concept_geo_entities_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT taxon_concept_geo_entities_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_concept_geo_entity_references_reference_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distribution_references
    ADD CONSTRAINT taxon_concept_geo_entity_references_reference_id_fk FOREIGN KEY (reference_id) REFERENCES "references"(id);


--
-- Name: taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distribution_references
    ADD CONSTRAINT taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk FOREIGN KEY (distribution_id) REFERENCES distributions(id);


--
-- Name: taxon_concept_references_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_references
    ADD CONSTRAINT taxon_concept_references_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: taxon_concept_references_reference_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_references
    ADD CONSTRAINT taxon_concept_references_reference_id_fk FOREIGN KEY (reference_id) REFERENCES "references"(id);


--
-- Name: taxon_concept_references_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_references
    ADD CONSTRAINT taxon_concept_references_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_concept_references_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_references
    ADD CONSTRAINT taxon_concept_references_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: taxon_concepts_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: taxon_concepts_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_parent_id_fk FOREIGN KEY (parent_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_concepts_rank_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_rank_id_fk FOREIGN KEY (rank_id) REFERENCES ranks(id);


--
-- Name: taxon_concepts_taxon_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_taxon_name_id_fk FOREIGN KEY (taxon_name_id) REFERENCES taxon_names(id);


--
-- Name: taxon_concepts_taxonomy_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_taxonomy_id_fk FOREIGN KEY (taxonomy_id) REFERENCES taxonomies(id);


--
-- Name: taxon_concepts_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: taxon_instruments_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_instruments
    ADD CONSTRAINT taxon_instruments_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: taxon_instruments_instrument_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_instruments
    ADD CONSTRAINT taxon_instruments_instrument_id_fk FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: taxon_instruments_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_instruments
    ADD CONSTRAINT taxon_instruments_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_instruments_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_instruments
    ADD CONSTRAINT taxon_instruments_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: taxon_relationships_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationships
    ADD CONSTRAINT taxon_relationships_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: taxon_relationships_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationships
    ADD CONSTRAINT taxon_relationships_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_relationships_taxon_relationship_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationships
    ADD CONSTRAINT taxon_relationships_taxon_relationship_type_id_fk FOREIGN KEY (taxon_relationship_type_id) REFERENCES taxon_relationship_types(id);


--
-- Name: taxon_relationships_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationships
    ADD CONSTRAINT taxon_relationships_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: term_trade_codes_pairs_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY term_trade_codes_pairs
    ADD CONSTRAINT term_trade_codes_pairs_term_id_fk FOREIGN KEY (term_id) REFERENCES trade_codes(id);


--
-- Name: term_trade_codes_pairs_trade_code_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY term_trade_codes_pairs
    ADD CONSTRAINT term_trade_codes_pairs_trade_code_id_fk FOREIGN KEY (trade_code_id) REFERENCES trade_codes(id);


--
-- Name: trade_annual_report_uploads_created_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_annual_report_uploads
    ADD CONSTRAINT trade_annual_report_uploads_created_by_fk FOREIGN KEY (created_by) REFERENCES users(id);


--
-- Name: trade_annual_report_uploads_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_annual_report_uploads
    ADD CONSTRAINT trade_annual_report_uploads_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: trade_annual_report_uploads_trading_country_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_annual_report_uploads
    ADD CONSTRAINT trade_annual_report_uploads_trading_country_id_fk FOREIGN KEY (trading_country_id) REFERENCES geo_entities(id);


--
-- Name: trade_annual_report_uploads_updated_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_annual_report_uploads
    ADD CONSTRAINT trade_annual_report_uploads_updated_by_fk FOREIGN KEY (updated_by) REFERENCES users(id);


--
-- Name: trade_annual_report_uploads_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_annual_report_uploads
    ADD CONSTRAINT trade_annual_report_uploads_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: trade_restriction_purposes_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_purposes
    ADD CONSTRAINT trade_restriction_purposes_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: trade_restriction_purposes_purpose_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_purposes
    ADD CONSTRAINT trade_restriction_purposes_purpose_id FOREIGN KEY (purpose_id) REFERENCES trade_codes(id);


--
-- Name: trade_restriction_purposes_trade_restriction_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_purposes
    ADD CONSTRAINT trade_restriction_purposes_trade_restriction_id FOREIGN KEY (trade_restriction_id) REFERENCES trade_restrictions(id);


--
-- Name: trade_restriction_purposes_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_purposes
    ADD CONSTRAINT trade_restriction_purposes_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: trade_restriction_sources_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_sources
    ADD CONSTRAINT trade_restriction_sources_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: trade_restriction_sources_source_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_sources
    ADD CONSTRAINT trade_restriction_sources_source_id FOREIGN KEY (source_id) REFERENCES trade_codes(id);


--
-- Name: trade_restriction_sources_trade_restriction_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_sources
    ADD CONSTRAINT trade_restriction_sources_trade_restriction_id FOREIGN KEY (trade_restriction_id) REFERENCES trade_restrictions(id);


--
-- Name: trade_restriction_sources_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_sources
    ADD CONSTRAINT trade_restriction_sources_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: trade_restriction_terms_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_terms
    ADD CONSTRAINT trade_restriction_terms_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: trade_restriction_terms_term_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_terms
    ADD CONSTRAINT trade_restriction_terms_term_id FOREIGN KEY (term_id) REFERENCES trade_codes(id);


--
-- Name: trade_restriction_terms_trade_restriction_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_terms
    ADD CONSTRAINT trade_restriction_terms_trade_restriction_id FOREIGN KEY (trade_restriction_id) REFERENCES trade_restrictions(id);


--
-- Name: trade_restriction_terms_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restriction_terms
    ADD CONSTRAINT trade_restriction_terms_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: trade_restrictions_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restrictions
    ADD CONSTRAINT trade_restrictions_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: trade_restrictions_end_notification_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restrictions
    ADD CONSTRAINT trade_restrictions_end_notification_id_fk FOREIGN KEY (end_notification_id) REFERENCES events(id);


--
-- Name: trade_restrictions_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restrictions
    ADD CONSTRAINT trade_restrictions_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: trade_restrictions_start_notification_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restrictions
    ADD CONSTRAINT trade_restrictions_start_notification_id_fk FOREIGN KEY (start_notification_id) REFERENCES events(id);


--
-- Name: trade_restrictions_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restrictions
    ADD CONSTRAINT trade_restrictions_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: trade_restrictions_unit_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restrictions
    ADD CONSTRAINT trade_restrictions_unit_id_fk FOREIGN KEY (unit_id) REFERENCES trade_codes(id);


--
-- Name: trade_restrictions_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_restrictions
    ADD CONSTRAINT trade_restrictions_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: trade_shipments_country_of_origin_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_country_of_origin_id_fk FOREIGN KEY (country_of_origin_id) REFERENCES geo_entities(id);


--
-- Name: trade_shipments_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: trade_shipments_exporter_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_exporter_id_fk FOREIGN KEY (exporter_id) REFERENCES geo_entities(id);


--
-- Name: trade_shipments_importer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_importer_id_fk FOREIGN KEY (importer_id) REFERENCES geo_entities(id);


--
-- Name: trade_shipments_purpose_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_purpose_id_fk FOREIGN KEY (purpose_id) REFERENCES trade_codes(id);


--
-- Name: trade_shipments_reported_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_reported_taxon_concept_id_fk FOREIGN KEY (reported_taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: trade_shipments_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_source_id_fk FOREIGN KEY (source_id) REFERENCES trade_codes(id);


--
-- Name: trade_shipments_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: trade_shipments_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_term_id_fk FOREIGN KEY (term_id) REFERENCES trade_codes(id);


--
-- Name: trade_shipments_trade_annual_report_upload_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_trade_annual_report_upload_id_fk FOREIGN KEY (trade_annual_report_upload_id) REFERENCES trade_annual_report_uploads(id);


--
-- Name: trade_shipments_unit_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_unit_id_fk FOREIGN KEY (unit_id) REFERENCES trade_codes(id);


--
-- Name: trade_shipments_updated_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_shipments
    ADD CONSTRAINT trade_shipments_updated_by_id_fk FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: trade_taxon_concept_code_pairs_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_taxon_concept_term_pairs
    ADD CONSTRAINT trade_taxon_concept_code_pairs_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: trade_taxon_concept_code_pairs_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_taxon_concept_term_pairs
    ADD CONSTRAINT trade_taxon_concept_code_pairs_term_id_fk FOREIGN KEY (term_id) REFERENCES trade_codes(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20120530135534');

INSERT INTO schema_migrations (version) VALUES ('20120703141230');

INSERT INTO schema_migrations (version) VALUES ('20121004124446');

INSERT INTO schema_migrations (version) VALUES ('20130620075330');

INSERT INTO schema_migrations (version) VALUES ('20130702093134');

INSERT INTO schema_migrations (version) VALUES ('20130702093702');

INSERT INTO schema_migrations (version) VALUES ('20130802130514');

INSERT INTO schema_migrations (version) VALUES ('20130802135401');

INSERT INTO schema_migrations (version) VALUES ('20130808132357');

INSERT INTO schema_migrations (version) VALUES ('20130808132441');

INSERT INTO schema_migrations (version) VALUES ('20130812101133');

INSERT INTO schema_migrations (version) VALUES ('20130814095805');

INSERT INTO schema_migrations (version) VALUES ('20130814103626');

INSERT INTO schema_migrations (version) VALUES ('20130816131841');

INSERT INTO schema_migrations (version) VALUES ('20130816172913');

INSERT INTO schema_migrations (version) VALUES ('20130820080014');

INSERT INTO schema_migrations (version) VALUES ('20130820080200');

INSERT INTO schema_migrations (version) VALUES ('20130916091657');

INSERT INTO schema_migrations (version) VALUES ('20130920185559');

INSERT INTO schema_migrations (version) VALUES ('20131005212713');

INSERT INTO schema_migrations (version) VALUES ('20131005215038');

INSERT INTO schema_migrations (version) VALUES ('20131014164845');

INSERT INTO schema_migrations (version) VALUES ('20131015150024');

INSERT INTO schema_migrations (version) VALUES ('20131017122309');

INSERT INTO schema_migrations (version) VALUES ('20131017123734');

INSERT INTO schema_migrations (version) VALUES ('20131017142454');

INSERT INTO schema_migrations (version) VALUES ('20131017163541');

INSERT INTO schema_migrations (version) VALUES ('20131018101540');

INSERT INTO schema_migrations (version) VALUES ('20131018134130');

INSERT INTO schema_migrations (version) VALUES ('20131022144429');

INSERT INTO schema_migrations (version) VALUES ('20131029165950');

INSERT INTO schema_migrations (version) VALUES ('20131106161335');

INSERT INTO schema_migrations (version) VALUES ('20131106162439');

INSERT INTO schema_migrations (version) VALUES ('20131106162824');

INSERT INTO schema_migrations (version) VALUES ('20131106163851');

INSERT INTO schema_migrations (version) VALUES ('20131119133659');

INSERT INTO schema_migrations (version) VALUES ('20131119140819');

INSERT INTO schema_migrations (version) VALUES ('20131119140820');

INSERT INTO schema_migrations (version) VALUES ('20131119164032');

INSERT INTO schema_migrations (version) VALUES ('20131212171122');

INSERT INTO schema_migrations (version) VALUES ('20131213140544');

INSERT INTO schema_migrations (version) VALUES ('20131216120901');

INSERT INTO schema_migrations (version) VALUES ('20131216121536');

INSERT INTO schema_migrations (version) VALUES ('20131217101949');

INSERT INTO schema_migrations (version) VALUES ('20131217102142');

INSERT INTO schema_migrations (version) VALUES ('20131217121051');

INSERT INTO schema_migrations (version) VALUES ('20131218164749');

INSERT INTO schema_migrations (version) VALUES ('20131218165627');

INSERT INTO schema_migrations (version) VALUES ('20131223110646');

INSERT INTO schema_migrations (version) VALUES ('20140108113028');

INSERT INTO schema_migrations (version) VALUES ('20140109175917');

INSERT INTO schema_migrations (version) VALUES ('20140110111239');

INSERT INTO schema_migrations (version) VALUES ('20140110111609');

INSERT INTO schema_migrations (version) VALUES ('20140113145605');

INSERT INTO schema_migrations (version) VALUES ('20140113160601');

INSERT INTO schema_migrations (version) VALUES ('20140113173344');

INSERT INTO schema_migrations (version) VALUES ('20140113173345');

INSERT INTO schema_migrations (version) VALUES ('20140116121054');

INSERT INTO schema_migrations (version) VALUES ('20140116134521');

INSERT INTO schema_migrations (version) VALUES ('20140116182242');

INSERT INTO schema_migrations (version) VALUES ('20140205084322');

INSERT INTO schema_migrations (version) VALUES ('20140207090849');

INSERT INTO schema_migrations (version) VALUES ('20140210121223');

INSERT INTO schema_migrations (version) VALUES ('20140210121403');

INSERT INTO schema_migrations (version) VALUES ('20140218105813');

INSERT INTO schema_migrations (version) VALUES ('20140220112825');

INSERT INTO schema_migrations (version) VALUES ('20140220171138');

INSERT INTO schema_migrations (version) VALUES ('20140221115708');

INSERT INTO schema_migrations (version) VALUES ('20140312145229');

INSERT INTO schema_migrations (version) VALUES ('20140313102554');

INSERT INTO schema_migrations (version) VALUES ('20140318132052');

INSERT INTO schema_migrations (version) VALUES ('20140326100059');

INSERT INTO schema_migrations (version) VALUES ('20140411143214');

INSERT INTO schema_migrations (version) VALUES ('20140513084035');

INSERT INTO schema_migrations (version) VALUES ('20140513084116');

INSERT INTO schema_migrations (version) VALUES ('20140513084500');

INSERT INTO schema_migrations (version) VALUES ('20140513090352');

INSERT INTO schema_migrations (version) VALUES ('20140514082045');

INSERT INTO schema_migrations (version) VALUES ('20140514082122');

INSERT INTO schema_migrations (version) VALUES ('20140514131633');

INSERT INTO schema_migrations (version) VALUES ('20140514131715');

INSERT INTO schema_migrations (version) VALUES ('20140514140438');

INSERT INTO schema_migrations (version) VALUES ('20140514141353');

INSERT INTO schema_migrations (version) VALUES ('20140514143438');

INSERT INTO schema_migrations (version) VALUES ('20140514143525');

INSERT INTO schema_migrations (version) VALUES ('20140514143916');

INSERT INTO schema_migrations (version) VALUES ('20140514143954');

INSERT INTO schema_migrations (version) VALUES ('20140514144222');

INSERT INTO schema_migrations (version) VALUES ('20140514144304');

INSERT INTO schema_migrations (version) VALUES ('20140519105842');

INSERT INTO schema_migrations (version) VALUES ('20140519105917');

INSERT INTO schema_migrations (version) VALUES ('20140520124510');

INSERT INTO schema_migrations (version) VALUES ('20140520124553');

INSERT INTO schema_migrations (version) VALUES ('20140520125612');

INSERT INTO schema_migrations (version) VALUES ('20140520125642');

INSERT INTO schema_migrations (version) VALUES ('20140520130258');

INSERT INTO schema_migrations (version) VALUES ('20140520130341');

INSERT INTO schema_migrations (version) VALUES ('20140520130708');

INSERT INTO schema_migrations (version) VALUES ('20140520130740');

INSERT INTO schema_migrations (version) VALUES ('20140520131040');

INSERT INTO schema_migrations (version) VALUES ('20140520131539');

INSERT INTO schema_migrations (version) VALUES ('20140520132248');

INSERT INTO schema_migrations (version) VALUES ('20140520132319');

INSERT INTO schema_migrations (version) VALUES ('20140521102836');

INSERT INTO schema_migrations (version) VALUES ('20140521102906');

INSERT INTO schema_migrations (version) VALUES ('20140521103243');

INSERT INTO schema_migrations (version) VALUES ('20140521103318');

INSERT INTO schema_migrations (version) VALUES ('20140521104850');

INSERT INTO schema_migrations (version) VALUES ('20140521104935');

INSERT INTO schema_migrations (version) VALUES ('20140521105017');

INSERT INTO schema_migrations (version) VALUES ('20140521105044');

INSERT INTO schema_migrations (version) VALUES ('20140521105116');

INSERT INTO schema_migrations (version) VALUES ('20140521105149');

INSERT INTO schema_migrations (version) VALUES ('20140521112702');

INSERT INTO schema_migrations (version) VALUES ('20140521112741');

INSERT INTO schema_migrations (version) VALUES ('20140521113436');

INSERT INTO schema_migrations (version) VALUES ('20140522125128');

INSERT INTO schema_migrations (version) VALUES ('20140523131927');

INSERT INTO schema_migrations (version) VALUES ('20140523150907');

INSERT INTO schema_migrations (version) VALUES ('20140528075844');

INSERT INTO schema_migrations (version) VALUES ('20140529073508');

INSERT INTO schema_migrations (version) VALUES ('20140530173241');

INSERT INTO schema_migrations (version) VALUES ('20140604100410');

INSERT INTO schema_migrations (version) VALUES ('20140611105359');

INSERT INTO schema_migrations (version) VALUES ('20140612174934');

INSERT INTO schema_migrations (version) VALUES ('20140625102632');

INSERT INTO schema_migrations (version) VALUES ('20140709084707');

INSERT INTO schema_migrations (version) VALUES ('20140709084708');

INSERT INTO schema_migrations (version) VALUES ('20140730083216');

INSERT INTO schema_migrations (version) VALUES ('20140730101120');

INSERT INTO schema_migrations (version) VALUES ('20140806122042');

INSERT INTO schema_migrations (version) VALUES ('20140811101246');

INSERT INTO schema_migrations (version) VALUES ('20140812133548');

INSERT INTO schema_migrations (version) VALUES ('20140814073530');

INSERT INTO schema_migrations (version) VALUES ('20140814074009');

INSERT INTO schema_migrations (version) VALUES ('20140814074055');

INSERT INTO schema_migrations (version) VALUES ('20140902113018');

INSERT INTO schema_migrations (version) VALUES ('20140910124718');

INSERT INTO schema_migrations (version) VALUES ('20140911100851');

INSERT INTO schema_migrations (version) VALUES ('20140911101846');

INSERT INTO schema_migrations (version) VALUES ('20140915075649');

INSERT INTO schema_migrations (version) VALUES ('20140915204931');

INSERT INTO schema_migrations (version) VALUES ('20140916154706');

INSERT INTO schema_migrations (version) VALUES ('20140918090432');

INSERT INTO schema_migrations (version) VALUES ('20140926121728');

INSERT INTO schema_migrations (version) VALUES ('20140929092236');

INSERT INTO schema_migrations (version) VALUES ('20141003104615');

INSERT INTO schema_migrations (version) VALUES ('20141003155548');

INSERT INTO schema_migrations (version) VALUES ('20141004213258');

INSERT INTO schema_migrations (version) VALUES ('20141004214703');

INSERT INTO schema_migrations (version) VALUES ('20141014125738');

INSERT INTO schema_migrations (version) VALUES ('20141119154955');

INSERT INTO schema_migrations (version) VALUES ('20141124163355');

INSERT INTO schema_migrations (version) VALUES ('20141128154019');

INSERT INTO schema_migrations (version) VALUES ('20141202120154');

INSERT INTO schema_migrations (version) VALUES ('20141202142048');

INSERT INTO schema_migrations (version) VALUES ('20141209092341');

INSERT INTO schema_migrations (version) VALUES ('20141209133037');

INSERT INTO schema_migrations (version) VALUES ('20141215104216');

INSERT INTO schema_migrations (version) VALUES ('20141215114029');

