class UpdateUser
  @queue = :lookup

  def self.perform(user_id)
    User.find(user_id).update!
  end
end
