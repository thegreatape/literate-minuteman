require 'rubygems'
require 'goodreads'
require 'open-uri'
require 'net/http'
require 'uri'
require 'hpricot'
require 'cgi'
require 'haml'
require 'pp'

def fetch(uri, headers=nil)
  uri = URI::parse(uri)
  req = Net::HTTP::Get.new(uri.path+'?'+uri.query, headers)
  res = Net::HTTP.start(uri.host, uri.port) {|http|
    http.request(req)
  } 
  return res
end

def find(title, author) 
  res = fetch(search_url(title, author))
  body = res.body
  pp res['Set-Cookie']

  (Hpricot(body)/'table.browseResult').map do |row|
    title = (row/'.dpBibTitle').inner_html

    more_links = (row/'.ThresholdContainer a')
    ajax_re = /return tapestry.linkOnClick\(this.href,/
    more_links &&= more_links[1]
    if more_links && more_links.attributes['onclick'] =~ ajax_re
      #locations = fetch_ajax_locations(cookie, more_links.attributes['href'])
      locations = []
      puts "better fetch #{more_links.attributes['href']}"
    else 
      locations = get_locations(row).flatten
    end
    
    {:title => title, :locations => Hash[*locations]} 
  end

end

def get_locations(row)
  (row/'table.itemTable tr' ).map { |loc|
    tds = loc/'td'
    [(tds[0]/'a').inner_html.strip, tds[2].inner_html.strip] unless tds.empty?
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
