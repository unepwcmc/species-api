# config valid only for current version of Capistrano
lock '3.18.0'

set :application, "species-api"
set :repo_url, 'git@github.com:unepwcmc/species-api.git'

set :rvm_type, :user
set :rvm_ruby_version, '3.2.5'

set :deploy_user, 'wcmc'
set :deploy_to, "/home/#{fetch(:deploy_user)}/#{fetch(:application)}"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
set :scm_username, "unepwcmc-read"

set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system','public/.well-known')
set :linked_files, %w{config/database.yml config/secrets.yml .env}

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

require 'yaml'
require 'json'

# snake_case to prevent injection
safe_stage = fetch(:stage).to_s.gsub(/\W+/, '_')
secrets = YAML.load(
  %x(bundle exec rails credentials:show -e #{safe_stage})
)

set :api_token, secrets['api_token'] # used in smoke testing

set :appsignal_config,
  push_api_key: secrets['appsignal_push_api_key'],
  active: true

set :slack_token, secrets['slack_exception_notification_webhook_url'] # comes from inbound webhook integration
set :slack_room, '#speciesplus' # the room to send the message to
set :slack_subdomain, 'wcmc' # if your subdomain is example.slack.com

set :slack_application, 'SAPI' # override Capistrano `application`
deployment_plants = [
  [ 'Ophrys apifera', ':white_flower:' ],
]

shuffle_deployer = deployment_plants.shuffle.first

set :slack_username, shuffle_deployer[0] # displayed as name of message sender
set :slack_emoji, shuffle_deployer[1] # will be used as the avatar for the message

require 'appsignal/capistrano'
