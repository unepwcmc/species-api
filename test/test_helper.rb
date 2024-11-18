require 'simplecov'

ENV['RAILS_ENV'] ||= 'test'

formatters = [SimpleCov::Formatter::HTMLFormatter]

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  formatters.push CodeClimate::TestReporter::Formatter
end


SimpleCov.formatter SimpleCov::Formatter::MultiFormatter.new([*formatters])
SimpleCov.start 'rails'
SimpleCov.command_name 'test'

require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'capybara/rails'
require 'json'

class ActiveSupport::TestCase
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  def sign_up user, opts = {}
    options = {
      terms_and_conditions: true
    }.merge(opts)
    visit new_user_registration_path
    within('#new_user') do
      fill_in 'Name', :with => user.name
      fill_in 'Email', :with => user.email
      fill_in 'Password', :with => user.password
      fill_in 'Password confirmation', :with => user.password
      fill_in 'Organisation', :with => user.organisation
      select 'Yes', from: 'user_is_cites_authority'
      find(:css, "#user_terms_and_conditions").set(options[:terms_and_conditions])
      click_button 'Sign up'
    end
  end

  def sign_in user
    visit new_user_session_path
    within('#new_user') do
      fill_in 'Email', :with => user.email
      fill_in 'Password', :with => user.password
      click_button 'Sign in'
    end
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end