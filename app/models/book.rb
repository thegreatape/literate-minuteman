class Book < ActiveRecord::Base
  has_many :users, through: :shelvings
  has_many :copies, dependent: :destroy

  def self.with_copies_at(locations)
    where("books.id in (select distinct(copies.book_id) from copies where copies.location_id in (?))", Array(locations))
  end

  def self.without_copies_at(locations)
    where("books.id not in (select distinct(copies.book_id) from copies where copies.location_id in (?))", Array(locations))
  end

  def self.with_copies
    where('books.id in (select distinct(copies.book_id) from copies)')
  end

  def self.without_copies
    where('books.id not in (select distinct(copies.book_id) from copies)')
  end

  def self.unsynced
    where('last_synced_at is null')
  end

  def self.with_sync_errors
    where('last_sync_error is not null')
  end

  def sync_copies
    now = Time.now

    LibrarySystem.all.each do |system|
      system.find(title, author).each do |scraped_book|
        location = Location.where(name: scraped_book.location, library_system_id: system.id).first_or_create

        copy = copies.where(location: location,
                            call_number: scraped_book.call_number,
                            title: scraped_book.title
                           ).first_or_create
        copy.update_attributes(
          last_synced_at: now,
          url: scraped_book.url,
          status: scraped_book.status)
      end
    end
    self.copies.where('last_synced_at < ?', now).destroy_all
    update_attributes(last_synced_at: now)

    BookNotifier.notify_all(self)
  end

end
