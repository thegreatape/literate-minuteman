class OnceAgainAddLastSyncedAtToBooks < ActiveRecord::Migration
  def change
    add_column :books, :last_synced_at, :timestamp
  end
end
