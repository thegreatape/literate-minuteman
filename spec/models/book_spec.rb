require 'spec_helper'

describe Book do
  context "book list syncing" do
    before do
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

    it "produce Copies" do
      expect( 2).to eq( @book.reload.copies.length )
      @book.copies.each do |copy|
        expect(copy.location).to_not be_nil
        expect(copy.location.library_system).to eq(@library_system)
        expect(copy.call_number).to_not be_nil
      end
    end

    it "not duplicate copies" do
      @book.sync_copies @list, @library_system
      expect(@book.reload.copies.length).to eq(2)
    end

    it "delete copies no longer on the list" do
      copy_count = Copy.count
      @book.sync_copies [@list.first], @library_system
      expect(Copy.count).to eq(copy_count - 1)
      expect(@book.reload.copies.length).to eq(1)
      expect(@book.copies.first.title).to eq(@list.first[:title])
    end

    it "update status" do
      @book.sync_copies [@list.first.merge(:status => 'Out')], @library_system
      expect(@book.reload.copies.first.status).to eq("Out")
    end

  end
end
