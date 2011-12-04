class LibrarySystem < ActiveRecord::Base
  has_many :locations
  has_and_belongs_to_many :users
  validates_presence_of :search_bot_class, :name

  def search_bot(goodreads_id)
    search_bot_class.constantize.new(goodreads_id)
  end
end
