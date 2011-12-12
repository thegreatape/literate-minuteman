require 'open-uri'
require 'net/http'
require 'uri'
require 'hpricot'
require 'cgi'
require 'uri'

module SearchBots
  class BplBot < AbstractBot
    def find(title, author) 
      res = fetch(search_url(title, author))
      (Hpricot(res.body)/'.searchResults .listItem').map { |row|
        title = (row/'.title a').first.attributes['title']
        availability_url = (row/'.availability a').first.attributes['href']
        location_html = fetch("http://bostonpl.bibliocommons.com#{availability_url}").body
        location_table = (Hpricot(location_html)/'.branch table').first
        (location_table/'tr').map { |loc|
          cells = loc/'td'
          if cells.length >= 3
            {:title => title,
             :location => cells[0].inner_text.gsub(/\(\d+\)\s*$/, '').strip,
             :status => cells[3].inner_text.strip
            }
          end
        }.compact 
      }.flatten.uniq
    end

    def search_url(title, author)
      title = title.gsub(/\(.*\)/,'').downcase
      author = author.downcase
      q = CGI::escape("#{title} #{author}")
      "http://bostonpl.bibliocommons.com/search?t=smart&search_category=keyword&q=#{q}&commit=Search"
    end
  end
end
