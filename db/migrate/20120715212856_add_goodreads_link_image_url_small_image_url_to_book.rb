class AddGoodreadsLinkImageUrlSmallImageUrlToBook < ActiveRecord::Migration
  def change
    add_column :books, :goodreads_link, :string
    add_column :books, :image_url, :string
    add_column :books, :small_image_url, :string
  end
end
