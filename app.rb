require 'rubygems'
require 'sinatra'
require 'sinatra/redis'
require 'haml'
require 'yaml'
require 'sass'
require 'set'
require 'bcrypt'
require 'pp'

set :redis, ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/0' 
enable :sessions

def signup(username, password)
  redis.hset("user:#{username}", 'username', username)
  redis.hmset("user:#{username}", 'password', BCrypt::Password.create(password))
  {'username' => username}
end

def authenticate(username, password)
  user = redis.hgetall "user:#{username}"
  unless user.empty?
    if BCrypt::Password.new(user['password']) == password
      {'username' => user['username']} 
    end
  end
end

def read_from_cache
   File.exists?('cache.yml') ?  YAML::load(IO.read('cache.yml')) : {}
end

def locations(books)
  set = SortedSet.new
  books.each do |book|
    book[:results].each do |result|
      set.merge result[:locations].keys
    end
  end
  set
end

def build_results(books, branch=nil)
  locs = locations(books)
  if branch
    books = books.map do |b| 
      b[:results] = b[:results].select do |r|
        locations = r[:locations].select {|name, avail| avail == "Available"}
        locations = locations.map {|l| l[0].gsub(/\s*\/\s*/, '-').downcase }
        locations.member? branch
      end
      b
    end
  end
  no_results, books = books.partition {|b| b[:results].empty?}

  {:books => books, 
   :no_results => no_results,
   :locations => locs,
   :branch => branch}
end

get '/style.css' do
  sass :style
end

get '/branch/:branch' do |branch|
  haml :index, :locals => build_results(read_from_cache, branch) 
end

get '/login' do
  haml :login, :locals => {:username => '', :errors => []}
end

post '/login' do
  user = authenticate(params[:username], params[:password])
  if user
    session[:username] = user['username'] 
    redirect '/' 
  else
    haml :login, :locals => {:username => params[:username], 
                             :errors => ['Username and password combination not found.']}
  end
end

get '/' do
  if session[:username]
    haml :index, :locals => build_results(read_from_cache) 
  else
    haml :intro
  end
end
