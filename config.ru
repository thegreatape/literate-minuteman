# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)
require 'sidekiq/web'

AUTH_PASSWORD = ENV['SIDEKIQ_PASSWORD']
if AUTH_PASSWORD
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD
  end
end

run Rack::URLMap.new \
  "/"        => Minuteman::Application,
  "/sidekiq" => Sidekiq::Web
