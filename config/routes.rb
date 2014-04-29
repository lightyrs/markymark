Markymark::Application.routes.draw do

  root to: 'home#index'

  resources :users, only: [ :show, :edit, :update ]

  get '/auth/:provider/callback' => 'sessions#create'
  get '/login/:provider' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/failure' => 'sessions#failure'

  resources :links do
    get 'tags', on: :collection
  end

  get '/links/tags/:tag' => 'links#index', as: 'tagged_links'
  get '/links/domains/(:site)' => 'links#index', as: 'domain_links', constraints: { site: /[^\/]+/ }

  resources :classifications, only: [ :index, :new, :create, :show, :update ]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
