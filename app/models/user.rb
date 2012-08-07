class User < ActiveRecord::Base
  has_and_belongs_to_many :library_systems
  has_and_belongs_to_many :locations
  attr_accessible :location_ids, :library_system_ids, :active_shelves

  has_many :books, :dependent => :destroy

  validates_uniqueness_of :goodreads_id

  serialize :shelves, Array
  serialize :active_shelves, Array

  def sync_books(list, library_system)
    return if list.empty?

    list.each do |b|
      book = books.find_or_create_by_title_and_author(b[:title], b[:author])
      book.update_attributes(last_synced_at:  Time.now,
                             goodreads_link:  b[:goodreads_link],
                             image_url:       b[:image_url],
                             small_image_url: b[:small_image_url])
      book.sync_copies b[:copies], library_system
    end
    self.last_synced_at = Time.now
    save!
  end

  def update!
    results = []
    library_systems.each do |system|
      bot = system.search_bot(goodreads_id)
      results = bot.lookup
      sync_books results, system
    end
    delete_books_not_on_list results
  end

  def delete_books_not_on_list(list)
    b = books
    list.each do |book|
      b = b.where('NOT (books.author = ? AND books.title = ?)', book[:author], book[:title])
    end
    b.destroy_all
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
    Goodreads::Client.new(access_token)
  end
  

end
