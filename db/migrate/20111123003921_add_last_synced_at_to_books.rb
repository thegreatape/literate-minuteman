class AddLastSyncedAtToBooks < ActiveRecord::Migration
  def change
    add_column :books, :last_synced_at, :datetime
  end
end
