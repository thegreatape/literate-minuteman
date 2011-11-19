require 'rubygems'
require 'open-uri'
require 'net/http'
require 'uri'
require 'hpricot'
require 'cgi'
require 'pp'

require 'bundler'
Bundler.setup
require 'goodreads'

class LookupAllUsers
  @queue = :lookup

  def self.perform
    client = Redis.new
    client.keys('user:*').each do |key|
      user = client.hgetall(key)
      puts "enqueuing #{user['username']} - #{user['goodreads_id']}"
      Resque.enqueue(ShelfLookupWorker, user['goodreads_id'])
    end
  end
end

class ShelfLookupWorker
  @queue = :lookup

  def self.perform(user_id)
    config = YAML::load(File.open('config.yml'))
    ShelfLookup.new(user_id, config['api_key']).lookup
  end
end

class ShelfLookup
  
 def initialize(user_id, api_key)
    @user_id = user_id
    @api_key = api_key
    @cookies = ''
  end

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
    (Hpricot(body)/'table.browseResult').map { |row|
      title = (row/'.dpBibTitle').text.strip.gsub(/\s\s+/, ' ')

      more_links = (row/'.ThresholdContainer a')
      ajax_re = /return tapestry.linkOnClick\(this.href,/
      more_links &&= more_links[1]
      if more_links && more_links.attributes['onclick'] =~ ajax_re
        res = fetch("http://find.minlib.net/#{more_links.attributes['href']}")
        locations = get_locations(Hpricot(res.body)).flatten
      else 
        locations = get_locations(row).flatten
      end
      
      {:title => title, :locations => Hash[*locations]} unless locations.empty?
    }.reject(&:nil?)

  end

  def titleize(str)
    str.downcase.gsub(/\b\w/){$&.upcase}
  end

  def get_locations(row)
    (row/'table.itemTable tr' ).map { |loc|
      tds = loc/'td'
      [(tds[0]/'a').inner_html.strip.split("/").map{ |v| titleize(v) }[0..-2].join(' / '), 
       titleize(tds[2].inner_html.strip.scan(/^(\w+).*/).first.first)] unless tds.empty?
    }.reject(&:nil?)
  end

  def search_url(title, author)
    title.gsub!(/\(.*\)/,'')
    title = CGI::escape("#{title} #{author}")
    "http://find.minlib.net/iii/encore/search/C%7CS#{title}%7COrightresult%7CU1?lang=eng&suite=pearl"
  end

  def lookup
    Goodreads.configure(@api_key)
    client = Goodreads::Client.new

    items = client.shelf(@user_id, 'to-read', :per_page => 100).books
    result = items.map do |entry| 
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
    write_to_cache result
  end

  def write_to_cache(books)
    client = Redis.new
    client.hset("books:#{@user_id}", 'results', YAML::dump(books))
    client.hset("books:#{@user_id}", 'last_updated', Time.now.to_s)
  end
end
