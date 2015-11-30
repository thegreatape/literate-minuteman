require 'spec_helper'

describe User do
  it "should have a unique goodreads_id" do
    user = create(:user)
    expect(build(:user, goodreads_id: user.goodreads_id)).to_not be_valid
  end

  it "has many library systems via the library_system_ids array" do
    user = create(:user, library_system_ids: ['minuteman', 'boston'])
    expect(user.library_systems).to_not include(LibrarySystem::MINUTEMAN, LibrarySystem::BOSTON)
  end

  context "getting user's current book list from Goodreads" do
    before do
      @user = create(:user, goodreads_id: '2003928', active_shelves: ['wishlist'])
    end

    it "fetches books from Goodreads" do
      VCR.use_cassette('updating shelves') do
        expect(@user.goodreads_books.length).to eq(116)
      end
    end

    it "adds books to the user" do
      VCR.use_cassette('updating shelves') do
        @user.sync_books
        expect(@user.books.length).to eq(116)
      end
    end

    it "removes books from the user's list not on the most recent list" do
      removed_book = Book.create!(title: 'Omg Wtf: A BBQ story')
      @user.shelvings.create!(book: removed_book, synced_at: 1.day.ago)
      VCR.use_cassette('updating shelves') do
        expect(@user.books.length).to eq(1)
        @user.sync_books
        @user.reload

        expect(@user.books.length).to eq(116)
        expect(Book.count).to eq(117)
      end
    end
  end

  it "updates shelves" do
    user = create(:user)
    stub_request(:get, %r|/www\.goodreads\.com/user/show|).
      to_return(body: fixture_file('goodreads_responses/user_show.xml'))

    expect(user.update_shelves).to be_truthy
    expect(user.shelves).to eq ["read", "currently-reading", "to-read", "photography", "wishlist"]
  end
end

