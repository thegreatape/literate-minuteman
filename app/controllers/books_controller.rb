class BooksController < ApplicationController
  before_filter :require_login, :find_books

  def index
  end
  
  private
  def find_books
    @books = @user.books.with_copies.paginate(:page => params[:page])
    @not_found = @user.books.without_copies
  end
end
