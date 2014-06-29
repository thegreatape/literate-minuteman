class AddLastSyncErrorToBooks < ActiveRecord::Migration
  def change
    add_column :books, :last_sync_error, :text
  end
end
