require 'sidekiq'
require 'sidekiq-status'
require 'sidekiq-unique-jobs'

# Asset precompilation boots Rails without runtime services or secrets. Skip
# Sidekiq setup for that build-only boot; every real process must still provide
# SIDEKIQ_REDIS_URL and fail fast when its runtime configuration is incomplete.
unless ENV['SECRET_KEY_BASE_DUMMY'] == '1'
  Sidekiq.configure_client do |config|
    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware unless Rails.env.test?
      chain.add SidekiqUniqueJobs::Middleware::Client
    end

    config.redis = {
      # Redis is an environment-specific service, so every runtime receives its
      # connection URL through the environment instead of encrypted credentials.
      url: ENV.fetch('SIDEKIQ_REDIS_URL')
    }
  end

  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes
      chain.add SidekiqUniqueJobs::Middleware::Server
    end

    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware unless Rails.env.test?
      chain.add SidekiqUniqueJobs::Middleware::Client
    end

    config.redis = {
      # Keep the server and client on the same explicitly configured Redis instance.
      url: ENV.fetch('SIDEKIQ_REDIS_URL')
    }

    SidekiqUniqueJobs::Server.configure(config)
  end
end
