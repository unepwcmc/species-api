Dir[Rails.root.join("test/support/models/*.rb")].each {|f| require f}

FactoryBot.define do
  factory :bulk_download, class: BulkDownload do
    nowish = Time.now
    io = StringIO.new('Surprise! Not a gzip stream')
    download_type = 'api_taxons_ndjson'
    filename = 'api_taxons.ndjson.gz'
    content_type = 'application/x-gzip-compressed'
    success_message = {
      stats: {
        record_count: 500,
        uncompressed_bytes: 100e3,
        compressed_bytes: 10e3,
        elapsed_time: 5.minutes.to_i * 1000,
      }
    }

    default_filters = {
      lang: 'en',
      taxonomy: 'CITES_EU',
    }

    completed_at { nowish }
    started_at { nowish - 5.minutes }
    expires_at { nowish + 3.weeks }
    download_type { download_type }
    format { content_type }
    success_message { success_message }
    filters { default_filters }

    after(:build) do |bd|
      bd.download.attach(
        io: File.open(
          Rails.root.join('test', 'fixtures', 'sample.dump.ndjson.gz')
        ),
        filename:,
        content_type:
      )
    end
  end
end
