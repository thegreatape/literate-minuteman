class GoodreadsBook
  ATTRIBUTES = :author, :title, :link, :image_url, :small_image_url
  attr_accessor *ATTRIBUTES

  def initialize(goodreads_response)
    self.author = goodreads_response.book.authors.author.name
    (ATTRIBUTES - [:author]).each do |key|
      self.public_send("#{key}=", goodreads_response.book.public_send(key))
    end
  end
end
