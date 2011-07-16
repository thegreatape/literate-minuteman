require 'rubygems'
require 'goodreads'
require 'open-uri'
require 'net/http'
require 'uri'
require 'hpricot'
require 'cgi'
require 'pp'

@cookies = ''
def fetch(uri)
  headers ||= {}
  uri = URI::parse(uri)
  req = Net::HTTP::Get.new(uri.path+'?'+uri.query, {'@cookies' => @cookies})
  res = Net::HTTP.start(uri.host, uri.port) {|http|
    http.request(req)
  } 
  @cookies = res['Set-Cookie'] if res['Set-Cookie']
  sleep 1
  return res
end

def find(title, author) 
  res = fetch(search_url(title, author))
  body = res.body
  (Hpricot(body)/'table.browseResult').map do |row|
    title = (row/'.dpBibTitle').inner_html

    more_links = (row/'.ThresholdContainer a')
    ajax_re = /return tapestry.linkOnClick\(this.href,/
    more_links &&= more_links[1]
    if more_links && more_links.attributes['onclick'] =~ ajax_re
      res = fetch("http://find.minlib.net/#{more_links.attributes['href']}")
      locations = get_locations(Hpricot(res.body)).flatten
    else 
      locations = get_locations(row).flatten
    end
    
    {:title => title, :locations => Hash[*locations]} 
  end

end

def get_locations(row)
  (row/'table.itemTable tr' ).map { |loc|
    tds = loc/'td'
    [(tds[0]/'a').inner_html.strip, tds[2].inner_html.strip.scan(/^(\w+).*/).first.first] unless tds.empty?
  }.reject(&:nil?)
end

def search_url(title, author)
  title = CGI::escape("#{title} / #{author}")
  "http://find.minlib.net/iii/encore/search/C%7CS#{title}%7COrightresult%7CU1?lang=eng&suite=pearl"
end

def lookup
  Goodreads.configure(@config['api_key'])
  client = Goodreads::Client.new

  #items = client.shelf(@config['user_id'], 'to-read', :per_page => 100).books
  items = [client.shelf(@config['user_id'], 'to-read', :per_page => 100).books.first]
  return items.map do |entry| 
    title = entry.book.title.strip
    author = entry.book.authors.author.name.strip
    puts "checking #{title} / #{author} ..."
    results = find(title, author)
    puts "Found #{results.length} possible candidates\n---"
    {:title => title,
     :author => author,
     :results => results
    }
  end
end

def write_to_cache(books)
   File.open('cache.json','w') { |f| f << books.to_json }
end

@config = YAML::load(File.open('config.yml'))
write_to_cache(lookup)
