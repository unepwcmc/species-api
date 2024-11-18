source 'https://rubygems.org'

gem 'rails', '5.2.8.1'

# Dependency resolution for Ruby 2.7.0
gem 'rdoc', '~> 5'

# Dependency resolution for Rails 5
gem 'railties', '5.2.8.1'
gem 'loofah', '~> 2.19.1'
gem 'rails-dom-testing', '~> 2.2.0'

# Use Puma as the app server
gem 'puma', '~> 3.11'

gem 'apipie-rails', '~> 0.6'

# devise provides authentication
gem 'devise', '>= 3.5.10'

# annotate maintains comments at the top of model files describing the schema,
# using the database as the source of truth
gem 'annotate', '3.1.0'

# Frontend CSS and minification
gem 'sass-rails', '5.0.7'
gem 'uglifier', '~> 2.7.2'
gem 'susy', '~> 2.2.14'
gem 'compass', '~> 1.0.3'
gem 'compass-rails', '~> 4.0.0'

# Frontend components
gem 'select2-rails', '~> 3.5.9.3'
gem 'chartkick', '~> 1.3.2'

# Provides group_by_day et al. on ActiveRecord models and queries
gem 'groupdate', '~> 6.2.1'

# pagination
gem 'will_paginate', '~> 4.0.0'
gem 'api_pagination_headers', '>= 2.1.1'

# i18n
gem 'traco', '~> 5.3.3' # TODO: switch to mobility

# HTTP user agent
gem 'httparty', '~> 0.22'

group :test do
  # Test assertion library.
  # UPGRADE TODO: Shoulda is tested and supported against Ruby 3.0+, Rails 6.1+,
  # RSpec 3.x, Minitest 4.x, and Test::Unit 3.x. For Ruby < 3 and Rails < 6.1
  # compatibility, please use v4.0.0.
  gem 'shoulda', '~> 4'

  # Integration testing
  gem 'capybara', '~> 2.8'

  # Helps build test fixtures
  gem 'factory_girl_rails', '~> 4.5.0' # UPGRADE TODO: gem 'factory_bot_rails', '4.11.1'

  # coverage reports
  gem 'simplecov', '~> 0.17.1', require: false
  # gem 'codeclimate-test-reporter', require: nil # UPGRADE: removed

  # Used in test/controllers/api/v1/taxon_concepts_test.rb to parse HTTP
  # link headers and verify they're correct
  gem 'link_header', '~> 0.0.8'

  # For laun
  # gem 'launchy', '~> 2.4.3'

  # Mocks and stubs. Not equivalent to https://mochajs.org/
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
gem 'oj', '~> 3'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1.1.0', group: :doc

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '~> 3.7.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 1.6.4'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Capistrano for rails deployment
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
  # A better debugger
  gem 'byebug', '~> 10.0.2'
end

# Error monitoring
gem 'appsignal', '~> 3.3.11'
