class BulkDownloads
  def create_bulk_download(generated)
    completed_at = Time.now
    started_at = completed_at - generated[:stats][:elapsed_time]
    expires_at = started_at + 3.weeks
    io = generated[:file]
    filename = generated[:filename]
    download_type = 'api_taxons_ndjson'
    content_type = 'application/x-gzip-compressed'
    success_message = { stats: generated[:stats] }
    filters = {
      lang: generated[:lang],
      taxonomy: generated[:taxonomy],
    }

    bd = BulkDownload.create!(
      completed_at:,
      download_type:,
      error_message: nil,
      expires_at: nil,
      filters:,
      format: content_type,
      is_public: true,
      started_at:,
      success_message:,
    )

    bd.download.attach io:, filename:, content_type:

    bd
  end

  def refresh_all
    generate_all_files() do |results|
      create_bulk_download(results)
    end
  end

  def generate_all_files
    each_language_and_taxonomy() do |options|
      generate_nd_json_gz_file(options) do |results|
        yield results
      end
    end
  end

  def each_language_and_taxonomy
    ['en', 'es', 'fr'].each do |lang|
      # 'CMS' not yet supported by API
      ['CITES_EU'].each do |taxonomy|
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
        :common_names,
        :cites_listings,
        :eu_listings,
        :eu_decisions,
        :distributions,
        :taxon_references,
        :cites_quotas_including_global,
        :cites_suspensions_including_global,
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

              # Calling this ensures the stream is not closed at the end of the
              # `Zlib::GzipWriter.wrap` block, so the temp file can be reused.
              gz.finish
            end
          end

        Rails.logger.debug "Written #{record_count} rows to #{filename}"

        compressed_bytes = file.size

        file.rewind

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
    # find_each uses a default batch size of 1000
    base_relation.find_each do |taxon_concept|
      taxon_concept_json =
        Api::V1::TaxonConceptsController.render(
          'api/v1/taxon_concepts/show',
          assigns: {
            taxon_concept: taxon_concept,
            is_dump: true,
          }
        )
      yield(taxon_concept_json)
    end
  end
end
