ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'shoulda'

module Resque
  def enqueue; end
end

class ActiveSupport::TestCase
  def fixture_file(path)
    IO.read("#{Rails.root}/test/fixtures/#{path}")
  end

  def login(user)
    session[:user_id] = user.id
  end
end

require 'capybara/rails'
Capybara.javascript_driver = :webkit
DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Stop ActiveRecord from wrapping tests in transactions
  self.use_transactional_fixtures = false

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end

  def login(user)
    visit '/login'
    fill_in 'email', with: user.email
    fill_in 'password', with: 'password'
    click_on 'Login'
  end
end
