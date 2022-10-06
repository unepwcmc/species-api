source 'https://rubygems.org'

gem 'rails', '4.2.5.2'
gem 'apipie-rails', '0.3.6' # Documentation
gem 'devise', '3.5.4'
gem 'annotate', '2.6.8'
gem 'sass-rails'#, '> 3.3.0' #,   '~> 3.2.3'
gem 'uglifier', '2.7.2' #, '>= 1.0.3'
gem 'susy', '1.0.9'
gem 'compass', '1.0.3' #, '>= 0.12.2'
gem 'compass-rails', '2.0.4' #, '>= 1.0.3'
gem 'will_paginate', '3.0.7' #, '~> 3.0.6'
gem 'api_pagination_headers', '2.0.1'
gem 'traco', '3.1.6'
gem 'httparty', '0.13.3'
gem 'select2-rails', '3.5.9.3'
gem 'groupdate', '2.4.0'
gem 'chartkick', '1.3.2'
gem 'nokogiri', '1.9'
gem 'ed25519', '1.2.4'
gem 'bcrypt_pbkdf', '1.1.0'

group :test do
  gem 'shoulda', '3.5.0'
  gem 'capybara', '2.4.4'
  gem 'factory_girl_rails', '4.5.0'
  gem 'simplecov', '0.9.2', require: false
  gem 'codeclimate-test-reporter', '0.4.7', require: nil
  gem 'link_header', '0.0.8'
  gem 'launchy', '2.4.3'
  gem 'mocha', '1.1.0'
end

group :staging, :production do
  gem 'dotenv-rails', '2.0.0'
end

# Use postgresql as the database for Active Record
gem 'pg', '0.18.1'
gem 'schema_plus', '1.8.7'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '3.1.4'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '2.5.3'
# Build JSON / XML API
gem 'rabl', '0.12.0'
# Also add either `oj` or `yajl-ruby` as the JSON parser
gem 'oj', '2.12.1'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', '1.6.3',        group: :development

group :development do
  gem 'capistrano', '3.16.0', require: false
  gem 'capistrano-rails', '1.6.2'
  gem 'capistrano-bundler', '2.0.1', require: false
  gem 'capistrano-rvm', '0.1.2', require: false
  gem 'capistrano-maintenance', '1.0', require: false
  gem 'capistrano-passenger', '0.2.1', require: false
  gem 'rack-cors', '0.4.0', :require => 'rack/cors'
end

group :development, :test do
  gem 'byebug', '11.0.1'
end

gem 'appsignal', '1.0.3'
