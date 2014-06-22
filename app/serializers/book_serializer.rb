class BookSerializer < ActiveModel::Serializer
  attributes :title, :author, :image_url, :id
  has_many :copies
end
