class UpdateUser
  include Sidekiq::Worker

  def perform(user_id)
    User.find(user_id).sync_books
  end
end
