require 'resque-retry'
require 'resque/failure/redis'
require 'resque-sentry'

if Rails.env.production?

  # [optional] custom logger value to use when sending to Sentry (default is 'root')
  Resque::Failure::Sentry.logger = "resque"

  Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis, Resque::Failure::Sentry]
  Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression
end
