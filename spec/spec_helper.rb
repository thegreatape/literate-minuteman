ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'factory_girl'
require 'capybara/rspec'
require 'capybara/rails'
require 'webmock/rspec'
require 'vcr'

if ENV["TRAVIS"].present?
  Capybara.default_wait_time = 240
  Capybara.register_driver :webkit do |app|
    Capybara::Poltergeist::Driver.new(app, timeout: 240)
  end
end

Capybara.javascript_driver = :poltergeist
Resque.stubs(:enqueue)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
  c.filter_sensitive_data("<GOODREADS_API_KEY>") { ENV['GOODREADS_API_KEY'] }
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = true
  config.order = "random"

  def login(user)
    UsersController.any_instance.stubs(:get_authorized_user).returns(user)
    User.any_instance.stubs(:update_shelves)
    visit oauth_callback_users_path
    User.any_instance.unstub(:update_shelves)
  end

  def fixture_file(path)
    IO.read("#{Rails.root}/spec/fixtures/#{path}")
  end
end
