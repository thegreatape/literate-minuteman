class Book < ActiveRecord::Base
  @per_page = 25
  default_scope :order => 'title ASC'
  belongs_to :user
  validates_presence_of :user

  has_many :copies

  scope :with_copies_at, lambda {|locations|
    locations = [locations] unless locations.is_a?(Enumerable)
    where("books.id in (select distinct(copies.book_id) from copies where copies.location_id in (#{locations.map(&:id).join(',')}))") 
  }
  scope :without_copies_at, lambda {|locations|
    locations = [locations] unless locations.is_a?(Enumerable)
    where("books.id not in (select distinct(copies.book_id) from copies where copies.location_id in (#{locations.map(&:id).join(',')}))")

  }
  scope :with_copies, lambda{ 
    where('books.id in (select distinct(copies.book_id) from copies)') 
  }
  scope :without_copies, lambda{ 
    where('books.id not in (select distinct(copies.book_id) from copies)') 
  }

  def sync_copies(list, library_system)
    now = Time.now
    list.each do |c|
      location = Location.find_or_create_by_name_and_library_system_id(c[:location], library_system.id)
      copy = copies.find_or_create_by_location_id_and_title(location.id, c[:title])
      copy.update_attributes(:last_synced_at => now, :status => c[:status])
    end
    copies.for_library_system(library_system).where('last_synced_at < ?', now).destroy_all
  end
end
