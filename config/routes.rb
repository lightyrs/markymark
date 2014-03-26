Markymark::Application.routes.draw do

  resources :links

  root to: 'home#index'

  resources :users, only: [ :index, :show, :edit, :update ]

  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', as: :signin
  get '/signout' => 'sessions#destroy', as: :signout
  get '/auth/failure' => 'sessions#failure'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
