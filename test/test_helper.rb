ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  def fixture_file(path)
    IO.read("#{Rails.root}/test/fixtures/#{path}")
  end

  def login(user)
    session[:user_id] = user.id
  end
end
