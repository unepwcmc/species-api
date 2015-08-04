source 'https://rubygems.org'

gem 'rails', '4.1.5'
gem 'apipie-rails' # Documentation
gem 'devise'
gem 'annotate'
gem 'sass-rails'#,   '~> 3.2.3'
gem 'uglifier'#, '>= 1.0.3'
gem 'susy', '~> 1.0.9'
gem 'compass'#, '>= 0.12.2'
gem 'compass-rails'#, '>= 1.0.3'
gem 'will_paginate' #, '~> 3.0.6'
gem 'api_pagination_headers'
gem 'traco'
gem 'httparty'
gem 'select2-rails'
gem 'groupdate'
gem "chartkick"

group :test do
  gem 'shoulda'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'simplecov', require: false
  gem 'codeclimate-test-reporter', require: nil
  gem 'link_header'
  gem 'launchy'
  gem 'mocha'
end

group :staging, :production do
  gem 'dotenv-rails'
  gem 'exception_notification', :git => 'https://github.com/smartinez87/exception_notification.git'
  gem 'slack-notifier', '~> 1.0'
end

# Use postgresql as the database for Active Record
gem 'pg'
gem 'schema_plus'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON / XML API
gem 'rabl'
# Also add either `oj` or `yajl-ruby` as the JSON parser
gem 'oj'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

group :development do
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-maintenance', '~> 1.0'
  gem 'capistrano-passenger', '~> 0.1.1', require: false
end


group :development, :test do
  gem 'byebug'
end
