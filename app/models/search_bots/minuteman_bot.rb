require 'open-uri'
require 'net/http'
require 'uri'
require 'hpricot'
require 'cgi'
require 'uri'

module SearchBots
  class MinutemanBot < AbstractBot

    def find(title, author) 
      res = fetch(search_url(title, author))
      body = res.body
      copies = (Hpricot(body)/'table.browseResult').map { |row|
        title = (row/'.dpBibTitle').text.strip.gsub(/\s\s+/, ' ')

        more_links = (row/'.ThresholdContainer a')
        ajax_re = /return tapestry.linkOnClick\(this.href,/
        more_links &&= more_links[1]
        if more_links && more_links.attributes['onclick'] =~ ajax_re
          res = fetch("http://find.minlib.net/#{more_links.attributes['href']}")
          locations = get_locations(Hpricot(res.body))
        else 
          locations = get_locations(row)
        end
        
        locations.map{ |l| {:title => title, :location => l[0], :status => l[1]}}
      }.flatten

    end

    private
    def get_locations(row)
      (row/'table.itemTable tr' ).map { |loc|
        tds = loc/'td'
        [(tds[0]/'a').inner_html.strip.split("/").map(&:titleize)[0..-2].join(' / '), 
         tds[2].inner_html.strip.scan(/^(\w+).*/).first.first.titleize] unless tds.empty?
      }.reject(&:nil?)
    end

    def search_url(title, author)
      title.gsub!(/\(.*\)/,'')
      title = CGI::escape("#{title} #{author}")
      "http://find.minlib.net/iii/encore/search/C%7CS#{title}%7COrightresult%7CU1?lang=eng&suite=pearl"
    end

  end
end
