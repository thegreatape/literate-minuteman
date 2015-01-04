class UpdateBook
  include Sidekiq::Worker
  sidekiq_options queue: :update_book, retry: 3

  def perform(book_id, library_system_id)
    book = Book.find(book_id)
    book.sync_copies(LibrarySystem.find(library_system_id))
    book.update_attributes(last_sync_error: nil)
  rescue StandardError => e
    error_lines = [e.class.name, e.to_s] + e.backtrace
    Book.find(book_id).update_attributes(last_sync_error: error_lines.join("\n"))
    raise e
  end
end
