# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)
require 'yaml' # for resque-web :-C

require 'resque/server'

run Rack::URLMap.new \
    "/"       => Minuteman::Application,
    "/resque" => Resque::Server.new
