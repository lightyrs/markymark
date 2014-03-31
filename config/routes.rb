Markymark::Application.routes.draw do

  root to: 'home#index'

  resources :users, only: [ :show, :edit, :update ]

  resources :links, only: [ :index, :show ]
  get '/links/tags/(:tag)' => 'links#index', as: 'tagged_links'
  get '/links/domains/(:domain)' => 'links#index', as: 'domain_links', constraints: { domain: /[^\/]+/ }

  get '/auth/:provider/callback' => 'sessions#create'
  get '/login/:provider' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/failure' => 'sessions#failure'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
