LookupStrategies::Minuteman = Struct.new(:title, :author) do
  def find
    copies.map do |copy|
      copy[:location] = normalize_location_name(copy[:location])
      ScrapedBook.new(copy.slice(*ScrapedBook::ATTRIBUTES))
    end
  end

  def copies
    LookupStrategies::Lyeberry.new('minuteman').copies(title, author)
  end

  def normalize_location_name(text)
    return text unless text.include?("/")

    parts = text.split("/")
    parts[0, parts.length-1].map(&:titleize).join('/')
  end
end
