desc "update all books"
task update_all_books: :environment do
  Book.find_each do |book|
    begin
      puts "\nupdating #{book.title}"
      book.sync_copies
    rescue StandardError => e
      puts e
    end
  end
end
