Markymark::Application.routes.draw do

  root to: 'home#index'

  resources :users, only: [ :show, :edit, :update ]

  get '/auth/:provider/callback' => 'sessions#create'
  get '/login/:provider' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/failure' => 'sessions#failure'

  resources :links, only: [ :index, :show ] do
    get 'tags', on: :collection
  end

  get '/links/tags/:tag' => 'links#index', as: 'tagged_links'
  get '/links/domains/(:site)' => 'links#index', as: 'domain_links', constraints: { site: /[^\/]+/ }

  get '/admin' => 'admin#index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
