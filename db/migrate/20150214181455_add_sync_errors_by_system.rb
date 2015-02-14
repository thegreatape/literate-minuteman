class AddSyncErrorsBySystem < ActiveRecord::Migration
  def change
    remove_column :books, :last_sync_error
    add_column :books, :sync_errors, :json, default: {}, null: false
  end
end
