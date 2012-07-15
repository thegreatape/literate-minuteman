class UsersController < ApplicationController
  before_filter :require_login, :except => [:login, :logout, :oauth_callback]

  def login
    request_token = get_consumer.get_request_token
    session[:oauth_token] = request_token.token
    session[:oauth_secret] = request_token.secret
    redirect_to request_token.authorize_url
  end

  def oauth_callback
    @user = get_authorized_user
    @user.update_shelves
    Resque.enqueue(UpdateUser, @user.id)

    session[:user_id] = @user.id
    redirect_to :controller => :books, :action => :index
  end

  def logout
    session[:user_id] = nil
    redirect_to '/'
  end

  def edit
  end

  def update
    params[:user] ||= {}
    params[:user][:location_ids] ||= []
    params[:user][:library_system_ids] ||= []

    if @user.update_attributes(params[:user])
      flash[:notice_good] = "Settings updated."
      redirect_to :controller => :books, :action => :index
    else 
      flash[:notice_bad] = "Couldn't save settings."
      render :edit
    end
  end

  private 
  def get_consumer 
    OAuth::Consumer.new(GOODREADS_API_KEY, 
                        GOODREADS_API_SECRET, 
                        :site => 'http://www.goodreads.com')
  end

  def get_authorized_user
    request_token = OAuth::RequestToken.new(get_consumer, session[:oauth_token], session[:oauth_secret])
    access_token = request_token.get_access_token
    client = Goodreads::Client.new(access_token)

    User.find_or_create_by_goodreads_id(client.user_id).tap do |user|
      user.update_attributes(oauth_access_token: access_token.token,
                             oauth_access_secret:  access_token.secret)
    end
  end
end
