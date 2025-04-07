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
    @downloads = get_latest_downloads

    with_storage_url_options do
      render 'api/v1/downloads/index'
    end
  end

  def latest
    @downloads = get_latest_downloads

    if @downloads[0]
      with_storage_url_options do
        redirect_to @downloads[0].download_url, external: true
      end
    else
      throw ActiveRecord::RecordNotFound.new('No latest download')
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

  def with_storage_url_options
    ActiveStorage::Current.set(
      url_options: { host: request.protocol + request.host_with_port }
    ) do
      yield if block_given?
    end
  end
end
