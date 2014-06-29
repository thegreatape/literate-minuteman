class UpdateBook
  @queue = :update_book

  def self.perform(book_id)
    book = Book.find(book_id)
    book.sync_copies
    book.update_attributes(last_sync_error: nil)
  rescue StandardError => e
    error_lines = [e.class.name, e.to_s] + e.backtrace
    Book.find(book_id).update_attributes(last_sync_error: error_lines.join("\n"))
    raise e
  end
end
