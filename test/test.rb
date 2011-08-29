ENV['RACK_ENV'] = 'test'
ENV['REDIS_URL'] = 'redis://127.0.0.1:6379/1'

require 'app'
require 'test/unit'
require 'rack/test'

module RedisTest 
  def setup
    uri = URI(ENV['REDIS_URL']) 
    @redis = Redis.new(
      :host => uri.host,
      :port => uri.port, 
      :db => uri.path[1..-1] 
    )
  end

  def teardown
    @redis.keys('*').each {|k| @redis.del(k) }
  end
end

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include RedisTest
  
  def app
    Sinatra::Application
  end

  def test_signup
    user = signup('bob', 'password')
    assert user
    stored_user = @redis.hgetall('user:bob')
    assert_equal 'bob', stored_user['username']
    # can't use assert_equals due to overloaded == operater on bcrypt password
    assert BCrypt::Password.new(stored_user['password']) == 'password' 
  end

  def test_login_good_username_and_password
    signup('bob', 'password')
    user = authenticate('bob', 'password')
    assert user
    assert_equal 'bob', user['username'] 
  end

  def test_login_good_username_bad_password
    signup('bob', 'password')
    assert_nil authenticate('bob', 'not-password')
  end

  def test_login_bad_username
    signup('bob', 'password')
    assert_nil authenticate('not-bob', 'not-password')
  end

  def test_get_login
    get '/login'
    assert last_response.ok?
  end

  def test_post_login
    signup('bob', 'password')
    post '/login', :username => 'bob', :password => 'password')
  end

end
