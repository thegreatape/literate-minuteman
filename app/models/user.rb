class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  has_and_belongs_to_many :locations

  has_many :shelvings
  has_many :books, through: :shelvings

  validates_uniqueness_of :goodreads_id

  serialize :shelves, Array
  serialize :active_shelves, Array

  def library_systems
    LibrarySystem.all.select {|system| library_system_ids.include? system.id }
  end

  def sync_books
    sync_time = Time.now
    goodreads_books.each do |goodreads_book|
      book = Book.where(title: goodreads_book.title, author: goodreads_book.author).first_or_create
      book.update_attributes(goodreads_link:  goodreads_book.link,
                             image_url:       goodreads_book.image_url,
                             small_image_url: goodreads_book.small_image_url)
      shelvings.where(book: book).first_or_create.update_attributes(synced_at: sync_time)
    end
    delete_unsynced_shelvings(sync_time)
  end

  def delete_unsynced_shelvings(sync_time)
    shelvings.where('synced_at < ?', sync_time).destroy_all
  end

  def goodreads_books
    client = Goodreads::Client.new(api_key: GOODREADS_API_KEY, api_secret: GOODREADS_API_SECRET)
    results = []
    active_shelves.each do |shelf|
      index = 1
      fetched = 0
      total = BigDecimal::INFINITY

      while total > fetched
        page = client.shelf(goodreads_id, shelf, per_page: 100, page: index)
        total = page.total
        fetched = page.end
        index += 1
        results += page.books
      end
    end
    results.map {|b| GoodreadsBook.new(b) }
  end

  def selected_locations
    if locations.any?
      locations
    else
      library_systems.collect(&:locations).flatten.sort_by(&:name)
    end
  end

  def self.authenticate(email, password)
    find_by_email(email).try(:authenticate, password)
  end

  def update_shelves
    self.shelves = client.user(goodreads_id).user_shelves.map(&:name)
    save!
  end

  def client
    consumer = OAuth::Consumer.new(GOODREADS_API_KEY,
                                   GOODREADS_API_SECRET,
                                   :site => 'http://www.goodreads.com')
    access_token = OAuth::AccessToken.new(consumer, oauth_access_token, oauth_access_secret)
    Goodreads::Client.new(oauth_token: access_token, api_key: GOODREADS_API_KEY, api_secret: GOODREADS_API_SECRET)
  end
end
