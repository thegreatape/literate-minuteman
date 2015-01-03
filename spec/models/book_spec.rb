require 'spec_helper'

describe Book do
  context "copy syncing" do
    before do
      @book = create(:book)
      LibrarySystem::MINUTEMAN.stub(:find).and_return [
        ScrapedBook.new(title: @book.title, location: "Main",    call_number: 'ABC', status: "In"),
        ScrapedBook.new(title: @book.title, location: "Concord", call_number: 'ABC', status: "Out")
      ]
      LibrarySystem::BOSTON.stub(:find).and_return []

    end

    it "produces new copies" do
      expect(@book.copies).to be_empty
      @book.sync_copies(LibrarySystem::MINUTEMAN)
      expect(@book.copies.length).to eq(2)
      expect(@book.copies.map(&:title)).to eq([@book.title, @book.title])
    end

    it "creates new locations on-demand" do
      create(:location, name: "Main", library_system_id: LibrarySystem::MINUTEMAN.id)

      expect(Location.count).to eq(1)
      @book.sync_copies(LibrarySystem::MINUTEMAN)
      expect(Location.count).to eq(2)
      expect(Location.pluck(:name)).to eq(["Main", "Concord"])
    end

    it "updates status of existing copies" do
      location = create(:location, name: "Main", library_system_id: LibrarySystem::MINUTEMAN.id)
      copy = create(:copy, book: @book, call_number: "ABC", title: @book.title, status: "Out", location: location)

      expect(@book.copies.length).to eq(1)
      @book.sync_copies(LibrarySystem::MINUTEMAN)
      expect(@book.reload.copies.length).to eq(2)
      expect(copy.reload.status).to eq("In")
    end

    it "delete copies no longer found" do
      location = create(:location, name: "Somewhere Else", library_system_id: LibrarySystem::MINUTEMAN.id)
      copy = create(:copy, book: @book, call_number: "ABC", title: @book.title, status: "Out", location: location, last_synced_at: 1.day.ago)

      expect(@book.copies.length).to eq(1)
      @book.sync_copies(LibrarySystem::MINUTEMAN)
      expect(@book.reload.copies.length).to eq(2)
      expect(@book.copies).to_not include(copy)
    end

    it "only deletes copies no longer found for the passed library system" do
      location = create(:location, name: "Somewhere Else", library_system_id: LibrarySystem::MINUTEMAN.id)
      copy = create(:copy, book: @book, call_number: "ABC", title: @book.title, status: "Out", location: location, last_synced_at: 1.day.ago)

      expect(@book.copies.length).to eq(1)
      @book.sync_copies(LibrarySystem::BOSTON)
      expect(@book.reload.copies.length).to eq(1)
      expect(@book.copies).to include(copy)
    end
  end
end
