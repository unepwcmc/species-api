class Api::V1::DownloadsController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/downloads'
    name 'Whole-database downloads'
  end

  api :GET, '/', 'Gets a link to the latest bulk download of the whole CITES/EU taxonomy'

  description <<-EOS
Note that download files are available as gzipped, newline-delimited JSON only,
regardless of whether this metadata endpoint was retrieved as JSON or XML.

Note: This feature is in beta and may change based on feedback.

`GET /api/v1/downloads/latest` will return a redirect to the latest download.

[lang] ISO 2-letter code indicating language - should be one of en, fr, es.
  EOS

  param :lang, String, :desc => "Language", :required => false

  example <<-EOS
  [
    {
      "id": 5,
      "filters": {
        "lang": "en",
        "taxonomy": "CITES_EU"
      },
      "format": "application/x-gzip-compressed",
      "started_at": "2025-04-01T16:00:17.463Z",
      "success_message": {
        "stats": {
          "elapsed_time": 299.37821418899875,
          "record_count": 89616,
          "compressed_bytes": 49427903,
          "uncompressed_bytes": 362830553
        }
      },
      "download_url": "https://api.speciesplus.net/.../cites_eu_en.ndjson.gz"
    }
  ]
  EOS

  example <<-EOS
  <?xml version="1.0" encoding="UTF-8"?>
  <bulk-downloads type="array">
    <bulk-download>
      <id type="integer">5</id>
      <filters>
        <lang>en</lang>
        <taxonomy>CITES_EU</taxonomy>
      </filters>
      <format>application/x-gzip-compressed</format>
      <started-at type="dateTime">2025-04-01T16:00:17Z</started-at>
      <success-message>
        <stats>
          <elapsed-time type="float">299.37821418899875</elapsed-time>
          <record-count type="integer">89616</record-count>
          <compressed-bytes type="integer">49427903</compressed-bytes>
          <uncompressed-bytes type="integer">362830553</uncompressed-bytes>
        </stats>
      </success-message>
      <download-url>https://api.speciesplus.net/.../cites_eu_en.ndjson.gz</download-url>
    </bulk-download>
  </bulk-downloads>
  EOS

  error code: 400, desc: "Bad Request"
  error code: 401, desc: "Unauthorized"
  error code: 404, desc: "Not Found"
  error code: 422, desc: "Unprocessable Entity"
  error code: 500, desc: "Internal Server Error"

  def index
    @downloads = get_latest_downloads

    with_storage_url_options do
      render 'api/v1/downloads/index'
    end
  end

  def latest
    @downloads = get_latest_downloads

    if @downloads[0]
      with_storage_url_options do
        download_url = @downloads[0].download.url expires_in: 1.hour

        redirect_to download_url, external: true
      end
    else
      raise ActiveRecord::RecordNotFound.new('No latest download')
    end
  end

  def permitted_params
    [ :taxonomy, :lang, :format ]
  end

  def get_latest_downloads(params = {})
    BulkDownload.where(
      download_type: 'api_taxons_ndjson',
      filters: {
        taxonomy: 'CITES_EU',
        lang: params[:lang] || 'en'
      },
      error_message: nil
    ).where.not(
      completed_at: nil
    ).where.not(
      success_message: nil
    ).order(
      'completed_at desc'
    ).limit(1)
  end

  ##
  # This must wrap any code which contains `record.download.url` so that
  # ActiveStorage knows the host and port with which to build the URL.
  # Otherwise, an error will be thrown `Cannot generate URL for`...
  def with_storage_url_options
    ActiveStorage::Current.set(
      url_options: { host: request.protocol + request.host_with_port }
    ) do
      yield if block_given?
    end
  end
end
