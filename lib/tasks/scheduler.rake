desc "Enqueue all users for lookup"
task :enqueue_all_users => :environment do
  puts "Queuing users for update..."
  QueueAllUsers.perform
  puts "done."
end

