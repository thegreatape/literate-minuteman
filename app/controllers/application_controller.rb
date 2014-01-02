class ApplicationController < ActionController::Base
  before_filter :find_user
  protect_from_forgery

  def require_login
    redirect_to welcome_path unless @user
  end

  def find_user
    @user = User.find(session[:user_id]) unless session[:user_id].nil?
  end
end
