class LookupStrategies::Boston
  include LookupStrategies::Browser

  attr_accessor :title, :author
  def initialize(title, author)
    self.title = title
    self.author = author
  end

  def find
    []
  end
end
