class UpdateBook
  include Sidekiq::Worker

  def perform(book_id, library_system_id)
    book = Book.find(book_id)
    book.sync_copies(LibrarySystem.find(library_system_id))
    if book.sync_errors.has_key?(library_system_id)
      book.update_attributes(sync_errors: book.sync_errors.reject{|k,v| k == library_system_id})
    end
  rescue StandardError => e
    error_lines = [e.class.name, e.to_s] + e.backtrace
    Book.find(book_id).update_attributes(sync_errors: {library_system_id => error_lines.join("\n")})
    raise e
  end
end
