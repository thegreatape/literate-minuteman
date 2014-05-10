require 'spec_helper'

describe BooksController do
  describe "GET" do
    before do
      @books = 3.times.map { create(:book) }
      @user = create(:user)
      @books.each {|b| @user.books << b }
      @user.save

      session[:user_id] = @user.id
    end

    it "returns the current user's books as JSON" do
      get :index, format: :json

      expect(response).to be_ok
      expect(response.body).to eq(ActiveModel::ArraySerializer.new(@books, each_serializer: BookSerializer, root: "books").to_json)
    end
  end
end
