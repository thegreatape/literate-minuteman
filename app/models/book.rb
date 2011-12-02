class Book < ActiveRecord::Base
  @per_page = 25
  default_scope :order => 'title ASC'
  belongs_to :user
  validates_presence_of :user

  has_many :copies

  scope :with_copies, lambda{ 
    where('books.id in (select distinct(copies.book_id) from copies)') 
  }
  scope :without_copies, lambda{ 
    where('books.id not in (select distinct(copies.book_id) from copies)') 
  }

  def sync_copies(list)
    now = Time.now
    list.each do |c|
      copy = copies.find_or_create_by_location_and_title(c[:location], c[:title])
      copy.update_attributes(:last_synced_at => now, :status => c[:status])
    end
    copies.where('last_synced_at < ?', now).destroy_all
  end
end
