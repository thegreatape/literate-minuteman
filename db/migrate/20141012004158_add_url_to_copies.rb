class AddUrlToCopies < ActiveRecord::Migration
  def change
    add_column :copies, :url, :text
  end
end
