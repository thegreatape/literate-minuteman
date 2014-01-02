class CreateShelvings < ActiveRecord::Migration
  def change
    create_table :shelvings do |t|
      t.integer :book_id
      t.integer :user_id
      t.timestamp :synced_at
    end
  end
end
