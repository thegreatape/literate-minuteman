Minuteman::Application.routes.draw do
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
  resources :sync_errors, only: [:index, :show]

  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username == ENV["RESQUE_WEB_HTTP_BASIC_AUTH_USER"] && password == ENV["RESQUE_WEB_HTTP_BASIC_AUTH_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"
end
