Markymark::Application.routes.draw do

  root to: 'home#index'

  resources :users, only: [ :show, :edit, :update ]

  get '/auth/:provider/callback' => 'sessions#create'
  get '/login/:provider' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/failure' => 'sessions#failure'

  resources :links do
    member do
      get 'refresh' => 'links#refresh', as: 'refresh'
    end
  end

  get '/tags' => 'links#tags', as: 'tags'
  get '/links/tags/:tag' => 'links#index', as: 'tagged_links'
  get '/links/domains/(:site)' => 'links#index', as: 'domain_links', constraints: { site: /[^\/]+/ }

  resources :classifications, only: [ :index, :new, :create, :show, :update ] do
    collection do
      post 'classify' => 'classifications#classify', as: 'classify'
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
