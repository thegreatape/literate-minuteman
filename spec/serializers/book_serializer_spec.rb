require 'spec_helper'

describe BookSerializer do
  it "has the expected fields" do
    book = create(
      :book,
      title: "Blindsight",
      author: "Peter Watts",
    )
    copies = [create(:copy, book: book)]
    book.copies = copies

    json = BookSerializer.new(book).as_json
    expect(json[:book][:title]).to eq "Blindsight"
    expect(json[:book][:author]).to eq "Peter Watts"
    expect(json[:book][:copies]).to eq ActiveModel::ArraySerializer.new(copies, each_serializer: CopySerializer).as_json
  end
end
