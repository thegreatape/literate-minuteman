module SearchBots
  class AbstractBot
    def initialize(user_id)
      @user_id = user_id
      @api_key = GOODREADS_API_KEY
      @cookies = ''
    end

    def find(title, author)
      raise NotImplementedError
    end

    def fetch(uri, headers={})
      uri = URI::parse(uri.gsub(' ', '%20'))
      query = uri.query ? "?#{uri.query}" : ''
      req = Net::HTTP::Get.new("#{uri.path}#{query}", {'cookie' => @cookies})
      headers.each {|k,v| req.add_field(k, v)}
      res = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(req)
      } 
      @cookies = res['Set-Cookie'] if res['Set-Cookie']

      # be nice to library servers!
      sleep 1
      case res
      when Net::HTTPFound
        loc = res['location'] || res['Location']
        unless loc.starts_with? ('http://')
          loc = "http://#{uri.host}#{loc}"
        end
        return fetch loc
      else 
        return res
      end
    end

    def lookup
      Goodreads.configure(@api_key)
      client = Goodreads::Client.new

      shelves = User.find_by_goodreads_id(@user_id).active_shelves
      shelves = ['to-read'] if shelves.empty?

      items = shelves.collect do |shelf| 
        client.shelf(@user_id, shelf, :per_page => 100).books
      end

      items.flatten.map do |entry| 
        title = entry.book.title.strip
        author = entry.book.authors.author.name.strip

        results = find(title, author) 
        {title:           title,
         author:          author,
         goodreads_link:  entry.book.link.strip,
         image_url:       entry.book.image_url.strip,
         small_image_url: entry.book.small_image_url.strip,
         copies: results }
      end
    end

  end
end
