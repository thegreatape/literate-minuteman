require 'rubygems'
require 'goodreads'
require 'open-uri'
require 'hpricot'
require 'cgi'
require 'haml'
require 'pp'

def find(title, author) 
  open(search_url(title, author)) { |body|
    (Hpricot(body)/'table.browseResult').map do |row|
      title = (row/'.dpBibTitle').inner_html

      puts row
      locations = (row/'table.itemTable tr' ).map do |loc|
        tds = loc/'td'
        #puts "empty row" if tds.empty?
        pp [(tds[0]/'a').inner_html.strip, tds[2].inner_html.strip] unless tds.empty?
        [(tds[0]/'a').inner_html.strip, tds[2].inner_html.strip] unless tds.empty?
      end
      puts "empty locations" if locations.empty?
      puts "--------------"
      locations = locations.reject {|i| i.nil? || i.empty?}.flatten
      {:title => title, :locations => Hash[*locations]} 
    end
  }.reject(&:nil?)

end

def search_url(title, author)
  title = CGI::escape("#{title} / #{author}")
  "http://find.minlib.net/iii/encore/search/C%7CS#{title}%7COrightresult%7CU1?lang=eng&suite=pearl"
end

config = YAML::load(File.open('config.yml'))
Goodreads.configure(config['api_key'])
client = Goodreads::Client.new

#items = client.shelf(config['user_id'], 'to-read')
items = [client.shelf(config['user_id'], 'to-read').first]
books = items.map do |entry| 
  title = entry.book.title.strip
  author = entry.book.authors.author.name.strip
  puts "checking #{title} / #{author} ..."
  results = find(title, author)
  puts "Found #{results.length} possible candidates"
  {:title => title,
   :author => author,
   :results => results
  }
end

haml = Object.new
engine = Haml::Engine.new(File.read('to-read.haml'))
engine.def_method(haml, :render, :books, :search_url)
  
file = File.open(config['out_file'] || 'to-read.html', 'w')
file.write(haml.render({
  :books => books, 
  :search_url => lambda  {|i| search_url(i)} 
}))
file.close
