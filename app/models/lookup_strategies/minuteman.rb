class LookupStrategies::Minuteman
  include LookupStrategies::Browser

  HOST = 'http://find.minlib.net/'

  attr_accessor :title, :author

  def initialize(title, author)
    self.title = title
    self.author = author
  end

  def find
    copies = []
    book_urls.each do |url|
      sleep 1

      session.visit "#{HOST}#{url}"

      title = session.all('#bibTitle').first.text
      author = session.find('.dpBibAuthor').try(:text)

      session.all('table.itemTable tr').each do |tr|
        cells = tr.all('td')
        next if cells.empty?

        copies << ScrapedBook.new(title: title,
                                  location: self.class.normalize_location_name(cells[0].text),
                                  call_number: cells[1].text,
                                  status: cells[2].text)
      end
    end

    copies.uniq
  end

  def self.normalize_location_name(text)
    parts = text.split("/")
    parts[0, parts.length-1].map(&:titleize).join('/')
  end

  def book_urls
    session.visit search_url

    urls = []
    session.all('.searchResult').map do |result|
      session.within result do
        urls << session.find('.title a')['href']
      end
    end
    urls
  end

  def search_url
    # some Goodreads titles have the series name in parenthesis, and search
    # results seem to be better when it's omitted
    param = URI::escape("#{title.gsub(/\(.*\)/,'')} #{author}")
    "#{HOST}/iii/encore/search/C__S#{param}__Orightresult__U?lang=eng&suite=cobalt"
  end
end
