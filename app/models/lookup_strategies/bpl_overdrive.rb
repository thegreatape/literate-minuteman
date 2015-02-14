LookupStrategies::BplOverdrive = Struct.new(:title, :author) do
  def find
    copies.map do |copy|
      copy[:location] = "BPL Overdrive"
      ScrapedBook.new(copy.slice(*ScrapedBook::ATTRIBUTES))
    end
  end

  def copies
    LookupStrategies::Lyeberry.new('bpl-overdrive').copies(title, author)
  end
end
