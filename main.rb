require 'rubygems'
require 'goodreads'
require 'open-uri'
require 'hpricot'

def check(isbn)
  open("http://library.minlib.net/search/?searchtype=i&SORT=D&searcharg=#{isbn}&searchscope=1") do |body|
    doc = Hpricot(body)
    (doc/'table.bibItems tr.bibItemsEntry').each do |entry|
      cells = entry/'td'
      puts "#{(cells[0]/'a').inner_html} : #{cells[2].inner_html.sub(/.*&nbsp;/, '')}"
    end
  end
end

config = YAML::load(File.open('config.yml'))
Goodreads.configure(config['api_key'])
client = Goodreads::Client.new

#items = client.shelf('twitchdotnet', 'to-read')
items = [client.shelf('twitchdotnet', 'to-read').first]
items.each do |entry| 
  puts "checking #{entry.book.title.strip}"
  check(entry.book.isbn)
  #sleep 1
end

