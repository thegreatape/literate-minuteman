desc "update all books"
task update_all_books: :environment do
  Book.find_each do |book|
    LibrarySystem.each do |library_system|
      begin
        puts "\nupdating #{book.title}"
        book.sync_copies(library_system)
      rescue StandardError => e
        puts e
      end
    end
  end
end
