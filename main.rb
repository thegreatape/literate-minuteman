require 'rubygems'
require 'goodreads'
require 'open-uri'
require 'hpricot'
require 'cgi'
require 'haml'

def by_isbn(isbn)
  open("http://library.minlib.net/search/?searchtype=i&SORT=D&searcharg=#{isbn}&searchscope=1") do |body|
    pairs = (Hpricot(body)/'table.bibItems tr.bibItemsEntry').map do |entry|
      cells = entry/'td'
      [(cells[0]/'a').inner_html, cells[2].inner_html.sub(/.*&nbsp;/, '').strip]
    end
    Hash[pairs]
  end
end

def by_title(title) 
  open(search_url(title)) do |body|
    pairs = (Hpricot(body)/'.briefcitRow .briefcitTitle a').map do |row|
      [row.inner_html, row.attributes['href']]
    end
    Hash[pairs]
  end

end

def search_url(title)
  title = CGI::escape(title)
  "http://library.minlib.net/search~S1/?searchtype=t&searcharg=#{title}&searchscope=1&SORT=D&extended=0&SUBMIT=Search&searchlimits="
end

config = YAML::load(File.open('config.yml'))
Goodreads.configure(config['api_key'])
client = Goodreads::Client.new

items = client.shelf(config[:user_id], 'to-read')
books = items.map do |entry| 
  puts "checking #{entry.book.title.strip} with ISBN #{entry.book.isbn}"
  isbn_results = by_isbn(entry.book.isbn)
  title_results = []
  sleep 1
  unless isbn_results.empty?
    puts "Found at #{isbn_results.length} branches."
  else
    puts "No results by ISBN, checking by title..."
    title_results = by_title(entry.book.title.strip).keys
    puts "Found #{title_results.length} possible candidates"
    sleep 1
  end
  {:title => entry.book.title.strip,
   :by_isbn => isbn_results,
   :by_title => title_results
  }
end

haml = Object.new
engine = Haml::Engine.new(File.read('to-read.haml'))
engine.def_method(haml, :render, :books, :search_url)
  
file = File.open(config[:out_file] || 'to-read.html', 'w')
file.write(haml.render({
  :books => books, 
  :search_url => lambda  {|i| search_url(i)} 
}))
file.close
