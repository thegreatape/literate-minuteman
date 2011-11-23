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
      @user.sync_book_list @list
    end

    should "produce Books" do
      assert_equal 2, @user.reload.books.length
    end

    should "not duplicate Books" do
      @user.sync_book_list @list
      assert_equal 2, @user.reload.books.length
    end

    should "delete books no longer on the list" do
      @user.sync_book_list [@list.first]
      assert_equal 1, @user.reload.books.length
      assert_equal @list.first[:title], @user.books.first.title
    end

  end

end
