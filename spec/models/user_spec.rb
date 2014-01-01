require 'spec_helper'

describe User do
  it "should have a unique goodreads_id" do
    user = Factory(:user)
    expect(build(:user, goodreads_id: user.goodreads_id)).to_not be_valid
  end

  context "book list syncing" do
    before do
      @list = [
        {:title => "The Areas of My Expertise",
         :author => "John Hodgeman",
         :copies => []},
        {:title => "Foucault's Pendulum",
         :author => "Umberto Eco",
         :copies => []}
      ]
      @user = Factory(:user)
      @library_system = Factory(:library_system)
      @user.sync_books @list, @library_system
    end

    it "produce Books" do
      expect(@user.reload.books.length).to eq(2)
    end

    it "not duplicate Books" do
      @user.sync_books @list, @library_system
      expect(@user.reload.books.length).to eq(2)
    end

    it "not delete or duplicate books from other library systems" do
      @user.sync_books @list, Factory(:library_system)
      expect(@user.reload.books.length).to eq(2)
    end
  end

  it "updates shelves" do
    user = Factory(:user)
    FakeWeb.register_uri(:get, %r|/www\.goodreads\.com/user/show|,
                         :body => fixture_file('goodreads_responses/user_show.xml'))

    expect(user.update_shelves).to be_true
    expect(user.shelves).to eq ["read", "currently-reading", "to-read", "photography", "wishlist"]
  end

  context "a full update of books" do
    before do
      FakeWeb.register_uri(:get, %r|/www\.goodreads\.com/review/list/|,
                           :body => fixture_file('goodreads_responses/gardens_of_the_moon.xml'))
      FakeWeb.register_uri(:get, %r|find.minlib.net.*Gardens\+of\+the\+Moon\+\+Steven\+Erikson|,
                           :body => fixture_file('search_bots/minuteman_bot/gardens_of_the_moon.html'))
      @user = Factory(:user,
                      :library_systems => [Factory(:library_system)],
                      :goodreads_id => '2003928')
      @user.update!
      @user.reload
    end

    after do
      FakeWeb.clean_registry
    end

    it "create 1 book" do
      expect(@user.books.length).to eq(1)
    end

    it "create 7 copies" do
      expect(@user.books.first.copies.length).to eq(7)
    end

  end

  context "with multiple library systems" do
    before do
      @system_a = Factory(:library_system, search_bot_class: 'SearchBots::OrangeNCBot')
      @system_b = Factory(:library_system, search_bot_class: 'SearchBots::MinutemanBot')

      @system_a.search_bot_class.constantize.any_instance.stubs(:lookup).returns( book('Title 1', 'Copley') + book('Title 2', 'Copley') )
      @system_b.search_bot_class.constantize.any_instance.stubs(:lookup).returns( book('Title 2', 'Alston') )
      @user = Factory(:user, library_systems: [@system_a, @system_b])

      @user.update!
      @user.reload
    end

    after do
      SearchBots::OrangeNCBot.any_instance.unstub(:lookup)
      SearchBots::MinutemanBot.any_instance.unstub(:lookup)
    end

    it "have copies from both libraries" do
      expect(@user.books.count).to eq(2)
    end
  end

  def book(title, location)
    [ {title: title,
       author: "John Hodgeman",
       copies: [{title: "The Areas of My Expertise",
                 status: "Out",
                 call_number: 'A325',
                 location: location }]
    } ]
  end

end
