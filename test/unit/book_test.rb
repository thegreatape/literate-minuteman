require 'test_helper'

class BookTest < ActiveSupport::TestCase
  context "book list syncing" do
    setup do 
      @list = [
        {:title => "The Areas of My Expertise",
         :status => 'In',
         :location => "Cambridge"},
        {:title => "Foucault's Pendulum",
         :status => 'Out',
         :location => "Allston"}
      ]
      @book = Factory(:book)
      @book.sync_copies @list
    end

    should "produce Copies" do
      assert_equal 2, @book.reload.copies.length
    end

    should "not duplicate copies" do
      @book.sync_copies @list
      assert_equal 2, @book.reload.copies.length
    end

    should "delete copies no longer on the list" do
      @book.sync_copies [@list.first]
      assert_equal 1, @book.reload.copies.length
      assert_equal @list.first[:title], @book.copies.first.title
    end

    should "update status" do
      @book.sync_copies [@list.first.merge(:status => 'Out')]
      assert_equal "Out", @book.reload.copies.first.status
    end

  end
end
