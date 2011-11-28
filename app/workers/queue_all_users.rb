class QueueAllUsers
  @queue = :lookup

  def self.perform
    User.find_each do |user|
      puts "enqueuing #{user.email} - goodreads id #{user.goodreads_id}"
      Resque.enqueue(UpdateUser, user.id)
    end
  end
end
