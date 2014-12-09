source 'https://rubygems.org'

gem 'apipie-rails' # Documentation
gem 'devise'
gem 'annotate'
gem 'sass-rails'#,   '~> 3.2.3'
gem 'uglifier'#, '>= 1.0.3'
gem "susy"
gem 'compass'#, '>= 0.12.2'
gem 'compass-rails'#, '>= 1.0.3'
gem 'will_paginate' #, '~> 3.0.6'
gem 'api_pagination_headers'

group :test do
  gem 'shoulda'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'simplecov', require: false
  gem 'codeclimate-test-reporter', require: nil
  gem 'link_header'
end

group :staging, :production do
  gem 'dotenv-rails'
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.1'
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
  gem 'capistrano', '~> 2.15.5'
  gem 'capistrano-ext'
  gem 'rvm-capistrano'
  gem 'brightbox', '~> 2.4.4'
end
