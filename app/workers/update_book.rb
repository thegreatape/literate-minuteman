class UpdateBook
  @queue = :update_book

  def self.perform(book_id)
    Book.find(book_id).sync_copies
  end
end
