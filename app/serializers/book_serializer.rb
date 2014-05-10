class BookSerializer < ActiveModel::Serializer
  attributes :title, :author
  has_many :copies
end
