class UpdateUser
  @queue = :update_user

  def self.perform(user_id)
    User.find(user_id).sync_books
  end
end
