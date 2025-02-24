class BulkDownloads
  def generate_all_files
    each_language_and_taxonomy() do |options|
      generate_nd_json_gz_file(options) do |results|
        yield results
      end
    end
  end

  def each_language_and_taxonomy
    ['en', 'es', 'fr'].each do |lang|
      ['CITES_EU', 'CMS'].each do |taxonomy|
        yield({
          lang:,
          taxonomy:,
        })
      end
    end
  end

  def generate_nd_json_gz_file(options)
    lang = options[:lang] || 'en'
    taxonomy = options[:taxonomy] || 'CITES_EU'
    taxonomy_is_cites_eu = 'CITES_EU' == taxonomy

    base_relation =
      TaxonConcept.where(
        taxonomy_is_cites_eu: taxonomy_is_cites_eu
      ).includes(
        :current_cites_additions,
        :common_names
      )

    I18n.with_locale(lang) do
      filename = "#{taxonomy.downcase}_#{lang}.ndjson.gz"

      Tempfile.open(
        filename,
        :encoding => 'ascii-8bit'
      ) do |file|
        Rails.logger.debug "Opened temp file #{filename}"

        record_count = 0
        uncompressed_bytes = 0

        elapsed_time =
          Benchmark.realtime do
            Zlib::GzipWriter.wrap(file) do |gz|
              generate_json(base_relation) do |taxon_concept_json|
                gz.write("#{taxon_concept_json}\n")

                record_count = record_count + 1
              end

              uncompressed_bytes = gz.pos
            end
          end

        Rails.logger.debug "Written #{record_count} rows to #{filename}"

        compressed_bytes = file.size

        yield({
          lang:,
          taxonomy:,
          file:,
          filename:,
          stats: {
            record_count:,
            uncompressed_bytes:,
            compressed_bytes:,
            elapsed_time:,
          }
        })
      end
    end
  end

  def generate_json(base_relation)
    base_relation.each do |taxon_concept|
      taxon_concept_json =
        Api::V1::TaxonConceptsController.render(
          'api/v1/taxon_concepts/show',
          assigns: { taxon_concept: taxon_concept }
        )
      yield(taxon_concept_json)
    end
  end
end
