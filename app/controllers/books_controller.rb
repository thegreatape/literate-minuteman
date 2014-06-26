class BooksController < ApplicationController
  before_filter :require_login
  before_filter :ensure_library_systems

  def index
    respond_to do |format|
      format.json { render json: @user.books.includes(copies: :location) }
      format.html {}
    end
  end

  def show
    render json: Book.find(params[:id])
  end

  private
  def ensure_library_systems
    if @user.library_systems.empty?
      return redirect_to edit_user_path(@user)
    end
  end
end

