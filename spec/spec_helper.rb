ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'shoulda'
require 'factory_girl'
require 'capybara/rspec'

class ActiveSupport::TestCase
  def login(user)
    session[:user_id] = user.id
  end
end

require 'capybara/rails'

if ENV["TRAVIS"].present?
  Capybara.default_wait_time = 240
  Capybara.register_driver :webkit do |app|
    Capybara::Webkit::Driver.new(app, timeout: 240)
  end
end

Capybara.javascript_driver = :webkit
UpdateUser.stubs(:perform_async)

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = true
  config.order = "random"

  def login(user)
    UsersController.any_instance.stubs(:get_authorized_user).returns(user)
    User.any_instance.stubs(:update_shelves)
    visit '/oauth-callback'
    User.any_instance.unstub(:update_shelves)
  end

  def fixture_file(path)
    IO.read("#{Rails.root}/spec/fixtures/#{path}")
  end
end
