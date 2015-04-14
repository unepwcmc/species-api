Apipie.configure do |config|
  config.app_name = "CITES Checklist/Species+ API"
  config.app_info = "Application Programming Interface (API) to support CITES Parties to increase the accuracy and efficiency of curating CITES species data for permitting purposes."
  config.api_base_url = "v1"
  config.doc_base_url = "/documentation"
  config.default_version = "v1"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v1/*.rb"
  config.layout = 'application'
  config.copyright = "&copy; #{Time.now.year} UNEP-WCMC"
end
