source 'http://rubygems.org'

ruby '2.1.0'
gem 'rails', '4.0.2'

gem 'pg'
gem 'haml'
gem 'hpricot'
gem 'goodreads'
gem 'oauth'
gem 'dynamic_form'
gem 'sidekiq'
gem 'sinatra' # for sidekiq-web
gem 'slim'
gem 'will_paginate'
gem 'thin'
gem 'newrelic_rpm'
gem 'airbrake'
gem 'json'
gem 'poltergeist'
gem 'capybara-screenshot'
gem 'active_hash'

# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test do
  gem 'rspec-rails'
  gem 'mocha', require: 'mocha/api'
  gem 'hashie'
  gem 'factory_girl_rails'
  gem 'webmock'
  gem 'database_cleaner'
  gem 'vcr'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails'
end

gem 'jquery-rails'

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'
