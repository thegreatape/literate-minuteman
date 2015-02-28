require 'spec_helper'

describe UpdateBook do
  class StubbedError < StandardError; end

  it "records errors when something blows up and re-raises them" do
    Book.any_instance.stub(:sync_copies) {|instance, book_id| raise StubbedError.new("oh no!") }
    book = create(:book)

    expect{ UpdateBook.new.perform(book.id, LibrarySystem::MINUTEMAN.id) }.to raise_error(StubbedError)
    book.reload
    expect(book.sync_errors).to_not be_nil
    expect(book.sync_errors).to have_key(LibrarySystem::MINUTEMAN.id)
    expect(book.sync_errors[LibrarySystem::MINUTEMAN.id]).to include("oh no!")
    expect(book.sync_errors[LibrarySystem::MINUTEMAN.id]).to include("StubbedError")
  end

  it "records clears previous errors when things go well" do
    Book.any_instance.stub(:sync_copies)
    book = create(:book, sync_errors: {
      LibrarySystem::MINUTEMAN.id => "things went poorly",
      LibrarySystem::BOSTON.id => "thing also went badly in Boston"
    })

    expect{ UpdateBook.new.perform(book.id, LibrarySystem::MINUTEMAN.id) }.to_not raise_error
    expect(book.reload.sync_errors).to eq({LibrarySystem::BOSTON.id => "thing also went badly in Boston"})
  end
end
