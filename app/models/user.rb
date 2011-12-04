class User < ActiveRecord::Base
  has_and_belongs_to_many :library_systems
  has_many :books, :dependent => :destroy

  validates_uniqueness_of :email
  validates_presence_of   :email
  validates_uniqueness_of :goodreads_id

  has_secure_password
  attr_accessible :email, :password, :password_confirmation

  def sync_books(list, library_system)
    return if list.empty?

    list.each do |b|
      book = books.find_or_create_by_title_and_author(b[:title], b[:author])
      book.update_attributes(:last_synced_at => Time.now)
      book.sync_copies b[:copies], library_system
    end
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

  def locations
    library_systems.collect(&:locations).flatten.sort_by(&:name)
  end


  def self.authenticate(email, password)
    find_by_email(email).try(:authenticate, password)
  end
  

end
