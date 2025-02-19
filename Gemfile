source 'https://rubygems.org'

gem 'rails', '7.1.5'

# must be 0.1.1 or deploy fails, due to conflict with bundler
gem 'base64', '0.1.1'

gem 'psych', '~> 4'

# Use Puma as the app server
gem 'puma', '~> 4.1'

gem 'apipie-rails', '~> 0.6'

# devise provides authentication
gem 'devise', '~> 4.9.4'

# Maintains comments at the top of model files describing the schema,
# using the database as the source of truth (replaces annotate).
gem 'annotaterb', '~> 4.13.0'

# Frontend CSS and minification
gem 'sass-rails', '~> 5.0.8'
gem 'terser', '~> 1.2.3'

# Frontend components
gem 'select2-rails', '~> 4.0.13'
gem 'chartkick', '~> 1.3.2'

# Provides group_by_day et al. on ActiveRecord models and queries
gem 'groupdate', '~> 6.2.1'

# pagination
gem 'will_paginate', '~> 4.0.0'
gem 'api_pagination_headers', '~> 2.1.1'

# i18n
gem 'traco', '~> 5.3.3' # TODO: switch to mobility

# HTTP user agent
gem 'httparty', '~> 0.22'

group :test do
  # Test assertion library.
  gem 'shoulda', '~> 5.0.0.rc1'

  # Integration testing
  gem 'capybara', '~> 2.8'

  # Helps build test fixtures
  gem 'factory_bot_rails', '~> 4.11.1'

  # coverage reports
  gem 'simplecov', '~> 0.17.1', require: false

  # Used in test/controllers/api/v1/taxon_concepts_test.rb to parse HTTP
  # link headers and verify they're correct
  gem 'link_header', '~> 0.0.8'

  # Mocks and stubs. Not equivalent to https://mochajs.org/
  gem 'mocha', '~> 1.1.0'
end

group :staging, :production do
  gem 'dotenv-rails'
end

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.2'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 5.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.6.0'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 2.5.3'

# Build JSON / XML API
gem 'rabl', '~> 0.16.1'

# Also add either `oj` or `yajl-ruby` as the JSON parser
gem 'oj', '~> 3'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1.1.0', group: :doc

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.18.4', require: false

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '~> 3.7.0'
  gem 'listen', '~> 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.0.0'
  gem 'spring-watcher-listen', '~> 2.1.0'

  # Capistrano for rails deployment
  gem 'capistrano', '3.18.0', require: false
  gem 'capistrano-rails', '1.6.3', require: false
  gem 'capistrano-bundler', '1.6.0', require: false
  gem 'capistrano-local-precompile', '1.2.0', require: false # NB: buggy on Ruby 3.2 - see comment in Capfile
  gem 'capistrano-rvm', '0.1.2', require: false
  gem 'capistrano-maintenance', '1.0.0', require: false
  gem 'capistrano-passenger', '0.2.0', require: false
  gem 'rack-cors', :require => 'rack/cors'

  # Used to fix capistrano-local-precompile on Ruby 3.2 - see comment in Capfile
  gem 'file_exists', '~> 0.2.0', require: false

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
