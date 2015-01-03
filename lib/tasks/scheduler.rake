desc "Enqueue all users for lookup"
task :refresh_all_users => :environment do
  User.find_each do |user|
    Resque.enqueue UpdateUser, user.id
  end
end

task :refresh_all_books => :environment do
  Book.find_each do |book|
    LibrarySystem.all.each do |library_system|
      Resque.enqueue UpdateBook, book.id, library_system.id
    end
  end
end

