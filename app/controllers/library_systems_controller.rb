class LibrarySystemsController < ApplicationController
  def show
    render library_system
  end

  private
  def library_system
    LibrarySystem.find(params[:id])
  end
end
