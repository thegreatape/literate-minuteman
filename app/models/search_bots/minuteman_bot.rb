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
        
        locations.map{ |l| {:title => title, 
                            :location => l[0], 
                            :status => normalize_status(l[1])}}
      }.flatten.uniq

    end

    private
    def normalize_status(s)
      case s
      when /available/i 
        return "In"
      else 
        return "Out"
      end
    end

    def get_locations(row)
      link = (row/'.dpBibTitle a')[0]
      return [] unless link
      href = link.attributes['href']
      id = CGI::unescape(href).match(/C__R([^_]*)__S/)[1] 
      res = fetch("http://library.minlib.net/record=#{id}").body
      File.open("#{Rails.root}/test/fixtures/search_bots/minuteman_bot/gardens_of_the_moon_records.html", 'w') {|f| f.write(res) }
      (Hpricot(res)/'table.bibItems .bibItemsEntry').map do |row|
        tds = row/'td'
        [(tds[0]/'a').inner_html.strip.split("/").map(&:titleize)[0..-2].join(' / '),
         tds[2].inner_html.strip.scan(/^(?:<!-- field % -->&nbsp;)(\w+).*/).first.first.titleize] unless tds.empty?
      end.reject(&:nil?)
    end

    def search_url(title, author)
      title.gsub!(/\(.*\)/,'')
      title = CGI::escape("#{title} #{author}")
      "http://find.minlib.net/iii/encore/search/C__S#{title}__Orightresult__U1?lang=eng&suite=pearl"
    end

  end
end
