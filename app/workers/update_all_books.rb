class UpdateAllBooks
  include Sidekiq::Worker

  def perform
    BookUpdater.update_all
  end
end
