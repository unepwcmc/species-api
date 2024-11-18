require_relative 'boot'

require 'rails/all'
require 'susy'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SpeciesPlusAPI
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Raises error for missing translations.
    # config.i18n.raise_on_missing_translations = true

    # Annotate rendered view with file names.
    # config.action_view.annotate_rendered_view_with_filenames = true

    config.active_record.schema_format = :sql

    if Rails.env == 'test'
      config.autoload_paths += [
        "#{config.root}/test/support/models",
      ]
    end

    config.autoload_paths += ["#{config.root}/lib"]
  end
end
