desc "Enqueue all users for lookup"
task :refresh_all_users => :environment do
  User.find_each do |user|
    Resque.enqueue UpdateUser, user.id
  end
end

task :refresh_all_books => :environment do
  Book.find_each do |book|
    Resque.enqueue UpdateBook, book.id
  end
end

