require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "book list syncing" do
    setup do 
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

    should "produce Books" do
      assert_equal 2, @user.reload.books.length
    end

    should "not duplicate Books" do
      @user.sync_books @list, @library_system
      assert_equal 2, @user.reload.books.length
    end

    should "not delete or duplicate books from other library systems" do
      @user.sync_books @list, Factory(:library_system)
      assert_equal 2, @user.reload.books.length
    end
  end

  test "goodreads_id should be unique" do
    user = Factory(:user)
    assert_raises(ActiveRecord::RecordInvalid) {Factory(:user, :goodreads_id => user.goodreads_id)}
  end

  test "updating shelves" do
    user = Factory(:user)
    FakeWeb.register_uri(:get, %r|/www\.goodreads\.com/user/show|,
                         :body => fixture_file('goodreads_responses/user_show.xml'))
    
    assert user.update_shelves
    assert_equal ["read", "currently-reading", "to-read", "photography", "wishlist"], user.shelves
  end

  context "a full update of books" do

    setup do
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

    teardown do 
      FakeWeb.clean_registry
    end

    should "create 1 book" do
      assert_equal 1, @user.books.length
    end

    should "create 7 copies" do
      assert_equal 7, @user.books.first.copies.length
    end

  end

  context "with multiple library systems" do
    setup do
      @system_a = Factory(:library_system, search_bot_class: 'SearchBots::OrangeNCBot') 
      @system_b = Factory(:library_system, search_bot_class: 'SearchBots::MinutemanBot') 

      @system_a.search_bot_class.constantize.any_instance.stubs(:lookup).returns( book('Title 1', 'Copley') + book('Title 2', 'Copley') )
      @system_b.search_bot_class.constantize.any_instance.stubs(:lookup).returns( book('Title 2', 'Alston') )
      @user = Factory(:user, library_systems: [@system_a, @system_b])

      @user.update!
      @user.reload
    end

    should "have copies from both libraries" do
      assert_equal 2, @user.books.count
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
