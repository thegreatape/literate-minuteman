require 'test_helper'

class BookTest < ActiveSupport::TestCase
  context "book list syncing" do
    setup do
      @list = [
        {:title => "The Areas of My Expertise",
         :status => 'In',
         :location => "Cambridge",
         :call_number => 'FICBLAH'},
        {:title => "Foucault's Pendulum",
         :status => 'Out',
         :call_number=>'FICBLAH2',
         :location => "Allston"}
      ]
      @book = Factory(:book)
      @library_system = Factory(:library_system)
      @book.sync_copies @list, @library_system
      Copy.update_all last_synced_at: 1.hour.ago
    end

    should "produce Copies" do
      assert_equal 2, @book.reload.copies.length
      @book.copies.each do |copy|
        assert_not_nil copy.location
        assert_equal @library_system, copy.location.library_system
        assert_not_nil copy.call_number
      end
    end

    should "not duplicate copies" do
      @book.sync_copies @list, @library_system
      assert_equal 2, @book.reload.copies.length
    end

    should "delete copies no longer on the list" do
      assert_difference "Copy.count", -1 do 
        @book.sync_copies [@list.first], @library_system
      end
      assert_equal 1, @book.reload.copies.length
      assert_equal @list.first[:title], @book.copies.first.title
    end

    should "update status" do
      @book.sync_copies [@list.first.merge(:status => 'Out')], @library_system
      assert_equal "Out", @book.reload.copies.first.status
    end

  end
end
