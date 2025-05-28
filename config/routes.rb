require 'sidekiq/web'
require 'sidekiq/cron/web'

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
