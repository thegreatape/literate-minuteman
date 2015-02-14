class SyncErrorsController < ApplicationController
  def index
    @errors = SyncErrorsPresenter.new
  end

  def show
    @book = Book.find(params[:id])
  end
end
