class AddLibrarySystemIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :library_system_ids, :string, array: true, default: '{}'
  end
end
