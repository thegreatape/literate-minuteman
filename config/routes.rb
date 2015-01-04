Minuteman::Application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  
  root 'welcome#index'

  resources :books
  resources :locations
  resources :library_systems, only: [:show]
  resources :users do
    collection do
      get :login
      get :logout
      get :oauth_callback
    end
  end
end
