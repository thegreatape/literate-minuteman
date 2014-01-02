class RemoveLastSyncedAtFromBooks < ActiveRecord::Migration
  def change
    remove_column :books, :last_synced_at
  end
end
