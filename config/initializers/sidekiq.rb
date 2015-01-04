Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDISTOGO_URL'] || 'redis://redis.example.com:7372/12' }
end
