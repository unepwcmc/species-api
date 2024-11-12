source 'https://rubygems.org'

gem 'rails', '5.0.7.2'

# Dependency resolution for Rails 5
gem 'railties', '5.0.7.2'
gem 'loofah', '~> 2.19.1'
gem 'nokogiri', '~> 1.6.0'
gem 'rails-dom-testing', '~> 2.0', '< 2.2.0'


gem 'apipie-rails', '~> 0.3.6' # Documentation
gem 'devise', '>= 3.5.10'
gem 'annotate', '3.1.0'
gem 'sass-rails', '5.0.7'
gem 'uglifier', '~> 2.7.2'
gem 'susy', '~> 2.2.14'
gem 'compass', '~> 1.0.3'
gem 'compass-rails', '~> 4.0.0'
gem 'will_paginate', '~> 3.0.7'
gem 'api_pagination_headers', '>= 2.1.1'
gem 'traco', '~> 3.1.6' # TODO: switch to mobility
gem 'httparty', '~> 0.13.3'
gem 'select2-rails', '~> 3.5.9.3'
gem 'groupdate', '~> 4.0.0'
gem "chartkick", '~> 1.3.2'

group :test do
  gem 'shoulda'
  gem 'capybara', '~> 2.8'
  gem 'factory_girl_rails', '~> 4.5.0' # UPGRADE TODO: gem 'factory_bot_rails', '4.11.1'
  gem 'simplecov', '~> 0.17.1', require: false
  # gem 'codeclimate-test-reporter', require: nil # UPGRADE: removed
  gem 'link_header', '~> 0.0.8'
  gem 'launchy', '~> 2.4.3'
  gem 'mocha', '~> 1.1.0'
end

group :staging, :production do
  gem 'dotenv-rails'
end

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.2'
# gem 'schema_plus', '~> 2.1.0' # was 1.8.7
gem 'schema_associations', '~> 1.2.7';
gem 'schema_auto_foreign_keys', '~> 0.1.3';
gem 'schema_validations', '~> 2.3.0';
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.6.0'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 2.5.3'
# Build JSON / XML API
gem 'rabl', '~> 0.14.0'
# Also add either `oj` or `yajl-ruby` as the JSON parser
gem 'oj', '~> 2.12.1'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', '~> 1.6.3', group: :development

group :development do
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.6.3'
  gem 'capistrano-bundler', '~> 2.1.1'
  gem 'capistrano-rvm', '~> 0.1.2'
  gem 'capistrano-maintenance', '~> 1.0', require: false
  gem 'capistrano-passenger', '~> 0.1.1', require: false
  gem 'rack-cors', :require => 'rack/cors'

  # Support ed25519 SSH keys
  gem 'rbnacl', '4.0.2'
  gem 'rbnacl-libsodium', '1.0.16'
  gem 'bcrypt_pbkdf', '1.1.0'
  gem 'ed25519', '1.2.4'
end

group :development, :test do
  gem 'byebug', '~> 4.0.2'
end

gem 'appsignal', '~> 3.3.11'
