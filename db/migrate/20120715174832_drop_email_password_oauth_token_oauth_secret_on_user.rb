class DropEmailPasswordOauthTokenOauthSecretOnUser < ActiveRecord::Migration
  def change
    remove_column :users, :email
    remove_column :users, :password_digest
    remove_column :users, :oauth_token
    remove_column :users, :oauth_secret
  end
end
