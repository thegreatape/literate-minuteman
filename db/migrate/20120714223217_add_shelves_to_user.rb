class AddShelvesToUser < ActiveRecord::Migration
  def change
    add_column :users, :shelves, :text
  end
end
