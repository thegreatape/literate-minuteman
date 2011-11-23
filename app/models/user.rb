class User < ActiveRecord::Base
  has_many :books

  def sync_book_list(list)
    now = Time.now
    list.each do |b|
      book = books.find_or_create_by_title_and_author(b[:title], b[:author])
      book.update_attributes(:last_synced_at => now)
      #book.sync_copies b[:copies]
    end
    books.where('last_synced_at < ?', now).destroy_all
  end
end
