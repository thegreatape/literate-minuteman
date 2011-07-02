require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml'
require 'sass'

def read_from_cache
   File.exists?('cache.yml') ?  YAML::load(IO.read('cache.yml')) : {}
end

get '/style.css' do
  sass :style
end

get '/' do
  haml :index, :locals => {:books => read_from_cache}
end
