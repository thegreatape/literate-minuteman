class UpdateUser
  include Sidekiq::Worker

  def perform(user_id)
    User.find(user_id).update!
  end
end
