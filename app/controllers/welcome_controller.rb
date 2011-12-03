class WelcomeController < ApplicationController
  before_filter :login_redirect

  def index
  end

  private
  def login_redirect
    redirect_to :controller => :books if @user.present?
  end

end
