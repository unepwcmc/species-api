class CreateApiTaxonConceptsView < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE TYPE higher_taxa AS (
      kingdom TEXT,
      phylum TEXT,
      class TEXT,
      "order" TEXT,
      family TEXT
    );

    CREATE TYPE simple_taxon_concept AS (
      id INT,
      full_name TEXT,
      author_year TEXT
    );
    SQL
    create_view :api_taxon_concepts_view, view_sql('20141209092341', 'api_taxon_concepts_view')
  end
end
