LookupStrategies::Boston = Struct.new(:title, :author) do
  def find
    copies.map do |copy|
      copy[:location] = normalize_location_name(copy[:location])
      ScrapedBook.new(copy.slice(*ScrapedBook::ATTRIBUTES))
    end
  end

  def copies
    LookupStrategies::Lyeberry.new('boston').copies(title, author)
  end

  private

  def normalize_location(name)
    # remove book count from location name
    name.gsub(/\s*\(\d+\)\s*/, '')
  end
end
