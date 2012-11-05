class QueueAllUsers

  def perform
    User.find_each do |user|
      puts "enqueuing #{user.id} - goodreads id #{user.goodreads_id}"
      UpdateUser.perform_asyn user.id
    end
  end
end
