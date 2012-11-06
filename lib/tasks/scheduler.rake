desc "Enqueue all users for lookup"
task :enqueue_all_users => :environment do
  puts "Queuing users for update..."
  User.find_each do |user|
    puts "Enqueuing user id #{user.id} | goodreads id #{user.goodreads_id}"
    UpdateUser.perform_async user.id
  end
  puts "done."
end

