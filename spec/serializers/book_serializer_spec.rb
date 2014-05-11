require 'spec_helper'

describe BookSerializer do
  it "has the expected fields" do
    book = create(
      :book,
      title: "Blindsight",
      author: "Peter Watts",
      image_url: 'http://lorempixel.com/10/10'
    )
    copies = [create(:copy, book: book)]
    book.copies = copies

    json = BookSerializer.new(book).as_json
    expect(json[:title]).to eq "Blindsight"
    expect(json[:author]).to eq "Peter Watts"
    expect(json[:image_url]).to eq "http://lorempixel.com/10/10"
    expect(json[:copies]).to eq ActiveModel::ArraySerializer.new(copies, each_serializer: CopySerializer).as_json
  end
end
