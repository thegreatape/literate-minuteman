LookupStrategies::MinutemanOverdrive = Struct.new(:title, :author) do
  def find
    copies.map do |copy|
      copy[:location] = "Minuteman Overdrive"
      ScrapedBook.new(copy.slice(*ScrapedBook::ATTRIBUTES))
    end
  end

  def copies
    LookupStrategies::Lyeberry.new('minuteman-overdrive').copies(title, author)
  end
end
