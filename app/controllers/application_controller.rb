class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_login
    @user = User.find(session[:user_id]) unless session[:user_id].nil?
    redirect_to :controller => :users, :action => :login unless @user
  end
end
