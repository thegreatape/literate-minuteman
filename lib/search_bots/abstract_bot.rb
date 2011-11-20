module SeachBots
  class AbstractBot
    def initialize(user_id, api_key)
      @user_id = user_id
      @api_key = api_key
      @cookies = ''
    end

    def find(title, author)
      raise NotImplementedError
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

    def lookup
      Goodreads.configure(@api_key)
      client = Goodreads::Client.new

      items = [client.shelf(@user_id, 'to-read', :per_page => 100).books.first]
      items.map do |entry| 
        title = entry.book.title.strip
        author = entry.book.authors.author.name.strip
        puts "checking #{title} / #{author} ..."
        results = find(title, author) 
        puts "Found #{results.length} possible candidates\n---"
        {:title => title,
         :author => author,
         :copies => results
        }
      end
    end

  end
end
