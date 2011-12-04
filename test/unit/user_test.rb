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

  test "username should be unique" do
    user = Factory(:user)
    assert_raises(ActiveRecord::RecordInvalid) {Factory(:user, :email => user.email)}
  end

  test "goodreads_id should be unique" do
    user = Factory(:user)
    assert_raises(ActiveRecord::RecordInvalid) {Factory(:user, :goodreads_id => user.goodreads_id)}
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

    should "create 6 copies" do
      assert_equal 6, @user.books.first.copies.length
    end

  end

end
