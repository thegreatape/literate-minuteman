class AddLastSyncedAtToCopies < ActiveRecord::Migration
  def change
    add_column :copies, :last_synced_at, :datetime
  end
end
