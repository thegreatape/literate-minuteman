LookupStrategies::Lyeberry = Struct.new(:lyeberry_id) do
  HOST = ENV['LYEBERRY_HOST']

  def copies(title, author)
    JSON.parse(HTTParty.get(search_url(title, author)).body).map(&:symbolize_keys)
  end

  def search_url(title, author)
    # some Goodreads titles have the series name in parenthesis, and search
    # results seem to be better when it's omitted
    "#{HOST}/systems/#{lyeberry_id}/books?title=#{URI::encode(title.gsub(/\(.*\)/,''))}&author=#{URI::encode(author)}"
  end
end
