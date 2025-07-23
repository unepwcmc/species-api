require 'sidekiq/web'
require 'sidekiq/cron/web'

if %w[test development].exclude?(Rails.env)
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    sidekiq_username = Rails.application.credentials.sidekiq.username!
    sidekiq_password = Rails.application.credentials.sidekiq.password!
    ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(username),
      Digest::SHA256.hexdigest(sidekiq_username)) &
      ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(password),
        Digest::SHA256.hexdigest(sidekiq_password))
  end
end

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'dashboard/index', as: 'dashboard'

  post 'dashboard/generate_new_token',
    to: 'dashboard#generate_new_token',
    as: 'generate_new_token'

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :downloads, only: [:index]

      get 'downloads/latest', to: 'downloads#latest'

      resources :taxon_concepts, only: [:index] do
        resources :cites_legislation, only: [:index]
        resources :distributions, only: [:index]
        resources :eu_legislation, only: [:index]
        resources :references, only: [:index]
      end
    end

    get 'test_exception_notifier', controller: :base, action: :test_exception_notifier
  end

  devise_for :users, :controllers => { registrations: "registrations" }

  apipie

  match 'nomenclature' => 'static_pages#nomenclature', via: [:get]

  mount Sidekiq::Web => '/sidekiq'

  root 'static_pages#index'
end
