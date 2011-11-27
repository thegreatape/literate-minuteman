class RenameUserColumns < ActiveRecord::Migration
  def up
    rename_column :users, :username, :email
    rename_column :users, :password, :password_digest
  end

  def down
    rename_column :users, :email, :username
    rename_column :users, :password_digest, :password
  end
end
