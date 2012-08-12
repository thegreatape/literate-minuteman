require 'open-uri'
require 'net/http'
require 'uri'
require 'hpricot'
require 'cgi'
require 'uri'

module SearchBots
  class OrangeNCBot < AbstractBot

    def find(title, author) 
      # seed the session with the appropriate search
      fetch(ref_url(title, author))

      # make an ajax req that'll actually have the search results in it
      res = fetch(search_url)
      (Hpricot(res.body) / 'table > tr').map { |tr|
        availability_link = (tr /  'a.results-title-link-avail').first 
        next unless availability_link.present?
        avail = fetch(availability_link.attributes['href'])
        title = (tr / '.nsm-brief-primary-title-group').first.inner_text.strip
        author = (tr / '.nsm-brief-primary-author-group').first.try(:inner_text).try(:strip)
        
        results = []
        current_loc = ''
        (Hpricot(avail.body) / 'tr').each do |row|
          case row.attributes['class']
          when 'location'
            current_loc = row.inner_text.strip.gsub(/\n.*$/,'')
          when 'piece'
            status = (row / 'td')[-2].inner_text.strip
            results.push({ status: normalize_status(status),
                           location: current_loc.clone,
                           title: "#{title} #{author}" })
          end
        end
        results
      }.flatten.compact
    end

    def search_url
      "http://catalog.co.orange.nc.us/POLARIS/search/components/ajaxResults.aspx?page=1"
    end

    def normalize_status(str)
      case str
      when "In"
        "In"
      else
        "Out"
      end
    end

    def ref_url(title, author)
      q = URI::encode("#{title} #{author}")
      "http://catalog.co.orange.nc.us/POLARIS/search/searchresults.aspx?ctx=3.1033.0.0.6&type=Keyword&term=#{q}&by=KW&sort=RELEVANCE&limit=((TOM=*)%20AND%20(AB=3%20OR%20AB=10%20OR%20OWN=3))&query=&page=0"
    end
  end
end
