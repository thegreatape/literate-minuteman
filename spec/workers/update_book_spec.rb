require 'spec_helper'

describe UpdateBook do
  class StubbedError < StandardError; end

  it "records errors when something blows up and re-raises them" do
    Book.any_instance.stub(:sync_copies) {|book_id| raise StubbedError.new("oh no!") }
    book = create(:book)

    expect{ UpdateBook.perform(book.id) }.to raise_error(StubbedError)
    expect(book.reload.last_sync_error).to_not be_nil
    expect(book.reload.last_sync_error).to include('StubbedError')
  end

  it "records clears previous errors when things go well" do
    Book.any_instance.stub(:sync_copies)
    book = create(:book, last_sync_error: "things went poorly")

    expect{ UpdateBook.perform(book.id) }.to_not raise_error
    expect(book.reload.last_sync_error).to be_nil
  end
end
