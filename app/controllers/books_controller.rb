class BooksController < ApplicationController
  before_filter :require_login

  def index
    respond_to do |format|
      format.json { render json: @user.books }
      format.html {}
    end
  end
end
