if ENV["REDISTOGO_URL"].present?
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)

end

require 'resque/server'
Resque::Server.class_eval do
  use Rack::Auth::Basic do |email, password|
    email == ENV['RESQUE_WEB_HTTP_BASIC_AUTH_USER'] &&
      password == ENV['RESQUE_WEB_HTTP_BASIC_AUTH_PASSWORD']
  end
end

