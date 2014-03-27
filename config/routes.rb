Markymark::Application.routes.draw do

  root to: 'home#index'

  resources :users, only: [ :index, :show ]

  resources :links

  get '/auth/:provider/callback' => 'sessions#create'
  get '/login/:provider' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/failure' => 'sessions#failure'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
