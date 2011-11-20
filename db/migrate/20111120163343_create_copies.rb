class CreateCopies < ActiveRecord::Migration
  def change
    create_table :copies do |t|
      t.string :title
      t.string :author
      t.string :call_number
      t.string :location
      t.integer :book_id
      t.string :status

      t.timestamps
    end
  end
end
