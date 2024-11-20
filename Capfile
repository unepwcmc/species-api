# Load environment variables
require 'dotenv'
Dotenv.load

# capistrano-local-precompile is buggy on Ruby 3.2 - it uses the deprecated
# `Dir.exists?` instead of `Dir.exist?`. This monkey-patches the old method
# back in. The issue was reported and a patch submitted in 2022:
#
# - https://github.com/stve/capistrano-local-precompile/issues/37
# - https://github.com/stve/capistrano-local-precompile/pull/38
require 'file_exists'

# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
# require 'capistrano/local_precompile'

# we don't ever want to run schema patches, the db is controlled by SAPI not species-api
# require 'capistrano/rails/migrations'
require 'capistrano/passenger'
require 'capistrano/maintenance'
require 'slackistrano'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
