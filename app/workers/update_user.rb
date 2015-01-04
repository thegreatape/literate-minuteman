class UpdateUser
  include Sidekiq::Worker
  sidekiq_options queue: :update_user

  def perform(user_id)
    User.find(user_id).sync_books
  end
end
