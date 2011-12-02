class BooksController < ApplicationController
  before_filter :require_login, :find_books

  def index
  end
  
  private
  def find_books
    @books = @user.books.with_copies
    @not_found = @user.books.without_copies
  end
end
