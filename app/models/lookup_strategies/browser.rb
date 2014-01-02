require 'capybara/rails'
require 'capybara/poltergeist'

module LookupStrategies::Browser
  def session
    @_session ||= begin
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, js_errors: false)
      end
      Capybara::Session.new(:poltergeist).tap do |session|
        session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
      end
    end
  end
end
