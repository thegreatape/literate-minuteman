class LookupStrategies::Minuteman
  include LookupStrategies::Browser

  HOST = ENV['LYEBERRY_HOST']

  attr_accessor :title, :author

  def initialize(title, author)
    self.title = title
    self.author = author
  end

  def find
    copies.map do |copy|
      copy[:location] = normalize_location_name(copy[:location])
      ScrapedBook.new(copy.slice(*ScrapedBook::ATTRIBUTES))
    end
  end

  def copies
    JSON.parse(HTTParty.get(search_url).body).map(&:symbolize_keys)
  end

  def normalize_location_name(text)
    return text unless text.include?("/")

    parts = text.split("/")
    parts[0, parts.length-1].map(&:titleize).join('/')
  end

  def search_url
    # some Goodreads titles have the series name in parenthesis, and search
    # results seem to be better when it's omitted
    "#{HOST}/systems/minuteman/books?title=#{URI::encode(title.gsub(/\(.*\)/,''))}&author=#{URI::encode(author)}"
  end
end
