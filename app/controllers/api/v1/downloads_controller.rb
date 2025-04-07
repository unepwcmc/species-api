class Api::V1::DownloadsController < Api::V1::BaseController
  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/downloads'
    name 'Whole-database Downloads'
  end

  api :GET, '/', 'Gets the latest download of the whole taxonomy'

  description <<-EOS
[lang] ISO 2-letter code indicating language - should be one of en, fr, es.
  EOS

  # param :taxonomy, String, :desc => "Taxonomy", :required => false

  error code: 400, desc: "Bad Request"
  error code: 401, desc: "Unauthorized"
  error code: 404, desc: "Not Found"
  error code: 422, desc: "Unprocessable Entity"
  error code: 500, desc: "Internal Server Error"

  def index
    @downloads = BulkDownload.where(
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

    ActiveStorage::Current.set(
      url_options: { host: request.protocol + request.host_with_port }
    ) do
      # redirect_to url, external: true
      render 'api/v1/downloads/index'
    end
  end

  def permitted_params
    [ :taxonomy, :lang, :format ]
  end
end
