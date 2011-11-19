class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :oauth_access_token
      t.string :oauth_access_secret
      t.string :goodreads_id

      t.timestamps
    end
  end
end
