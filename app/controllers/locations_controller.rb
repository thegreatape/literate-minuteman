class LocationsController < ApplicationController
  before_filter :find_location
  def show
    @books = @user.books.with_copies_at(@location).paginate(:page => params[:page])
    @books_elsewhere = @user.books.without_copies_at(@location).paginate(:page => params[:page])
    @not_found = @user.books.without_copies
    @locations = @user.selected_locations
  end

  private
  def find_location
    @location = Location.find(params[:id])
  end
end
