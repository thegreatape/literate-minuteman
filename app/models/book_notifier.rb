class BookNotifier
  def self.book_update_channel_name(user)
    "user-book-updates-#{user.id}"
  end

  def self.pending_book_channel_name(user)
    "user-pending-books-#{user.id}"
  end

  def self.notify(user, book)
    Pusher[book_update_channel_name(user)].trigger('book-updated', {id: book.id})
    Pusher[pending_book_channel_name(user)].trigger('pending-count-updated', {
      count: user.books.unsynced.count
    })
  end

  def self.notify_all(book)
    Shelving.where(book: book).find_each do |shelving|
      notify shelving.user, book
    end
  end
end
