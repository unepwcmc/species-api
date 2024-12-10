# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# select2-rails 3.5.10 https://rubygems.org/gems/select2-rails/versions/3.5.10
Rails.application.config.assets.precompile += %w[
  select2.png select2-spinner.gif select2x2.png
]
