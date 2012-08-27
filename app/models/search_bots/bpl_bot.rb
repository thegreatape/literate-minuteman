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
        availability_link = (row/'.availability a').first
        next if !availability_link
        availability_url = availability_link.attributes['href']
        location_html = fetch("http://bostonpl.bibliocommons.com#{availability_url}").body
        location_table = (Hpricot(location_html)/'.branch table').first
        status_idx = (location_table / 'th').index {|i| i.attributes['class'] == 'status'}
        call_number_idx = (location_table / 'th').index {|i| i.attributes['class'] == 'call_no'}
        (location_table/'tr').map { |loc|
          cells = loc/'td'
          if cells.compact.length > 3
            {:title => title,
             :location => cells[0].inner_text.gsub(/\(\d+\)\s*$/, '').strip,
             :call_number => cells[call_number_idx].inner_text.strip,
             :status => normalize_status(cells[status_idx].inner_text.strip)
            }
          end
        }
      }.flatten.compact.uniq
    end
    
    def normalize_status(str)
      case str
      when "In Library"
        "In"
      else
        "Out"
      end
    end

    def search_url(title, author)
      title = title.gsub(/\(.*\)/,'').downcase
      author = author.downcase
      q = CGI::escape("#{title} #{author}")
      "http://bostonpl.bibliocommons.com/search?t=smart&search_category=keyword&q=#{q}&commit=Search"
    end
  end
end
