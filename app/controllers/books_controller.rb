class BooksController < ApplicationController
  before_filter :require_login, :find_books

  def index
  end

  private
  def find_books
    if @user.locations.any?
      @books = @user.books.with_copies_at(@user.locations)
    else
      @books = @user.books.with_copies
    end
    @books = @books.paginate(:page => params[:page])
    @not_found = @user.books.without_copies
    @locations = @user.selected_locations
  end
end
