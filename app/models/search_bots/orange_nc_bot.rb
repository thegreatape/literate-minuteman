require 'open-uri'
require 'net/http'
require 'uri'
require 'hpricot'
require 'cgi'
require 'uri'

module SearchBots
  class OrangeNCBot < AbstractBot

    def find(title, author) 
      fetch(ref_url(title, author))
      fetch(search_url)
    end

    def search_url
      "http://catalog.co.orange.nc.us/POLARIS/search/components/ajaxResults.aspx?page=1"
    end

    def ref_url(title, author)
      q = URI::encode("#{title} #{author}")
      "http://catalog.co.orange.nc.us/POLARIS/search/searchresults.aspx?ctx=3.1033.0.0.6&type=Keyword&term=#{q}&by=KW&sort=RELEVANCE&limit=((TOM=*)%20AND%20(AB=3%20OR%20AB=10%20OR%20OWN=3))&query=&page=0"
    end
  end
end
