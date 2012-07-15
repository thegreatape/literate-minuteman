class AddActiveShelvesToUser < ActiveRecord::Migration
  def change
    add_column :users, :active_shelves, :text
  end
end
