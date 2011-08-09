require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml'
require 'sass'
require 'set'
require 'pp'

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

get '/style.css' do
  sass :style
end

get '/branch/:branch' do |branch|
  books = read_from_cache
  locs = locations(books)
  books = books.map do |b| 
    b[:results] = b[:results].select do |r|
      locations = r[:locations].select {|name, avail| avail == "Available"}
      locations = locations.map {|l| l[0].gsub(/\s*\/\s*/, '-').downcase }
      locations.member? branch
    end
    b
  end
  haml :index, :locals => {:books => books, :locations => locs}
end

get '/' do
  books = read_from_cache
  haml :index, :locals => {:books => read_from_cache, :locations => locations(books)}
end
