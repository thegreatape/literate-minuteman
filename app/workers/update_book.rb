class UpdateBook
  include Sidekiq::Worker

  def perform(book_id)
    Book.find(book_id).sync_copies
  end
end
