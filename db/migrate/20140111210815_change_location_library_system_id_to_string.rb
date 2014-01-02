class ChangeLocationLibrarySystemIdToString < ActiveRecord::Migration
  def change
    change_column :locations, :library_system_id, :string
  end
end
