class BookSerializer < ActiveModel::Serializer
  attributes :title, :author, :image_url
  has_many :copies
end
