desc "update all books"
task update_all_books: :environment do
  Book.find_each do |book|
    LibrarySystem.all.each do |library_system|
      begin
        puts "\nupdating #{book.title} for #{library_system.name}"
        book.sync_copies(library_system)
      rescue StandardError => e
        puts e
      end
    end
  end
end
