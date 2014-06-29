class BookSerializer < ActiveModel::Serializer
  attributes :title, :author, :image_url, :id, :goodreads_link
  has_many :copies
end
