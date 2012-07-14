class UsersController < ApplicationController
  before_filter :require_login, :except => [:signup, :login]

  def signup
    render :signup && return unless request.post?

    @user = User.create(params[:user])
    if @user.save
      request_token = get_consumer.get_request_token
      @user.update_attribute(:oauth_token, request_token.token)
      @user.update_attribute(:oauth_secret, request_token.secret)
      session[:user_id] = @user.id
      redirect_to request_token.authorize_url
    else
      render :signup
    end
  end

  def oauth_callback
    @user = User.where(:oauth_token => params[:oauth_token]).first
    request_token = OAuth::RequestToken.new(get_consumer, @user.oauth_token, @user.oauth_secret)
    access_token = request_token.get_access_token
    client = Goodreads::Client.new(access_token)
    @user.goodreads_id = client.user_id
    @user.oauth_token = access_token.token
    @user.oauth_secret = access_token.secret
    @user.save
    redirect_to :controller => :books, :action => :index
  end

  def login
    render :login && return if request.get?

    user = User.authenticate(params[:email], params[:password]) 
    if user
      session[:user_id] = user.id
      redirect_to '/'
    else
      render :login, :locals => {:errors => ["Email and password combination not found."]}
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to '/'
  end

  def library_systems
  end

  def save_library_systems
    @user.library_systems.clear
    if params[:systems]
      params[:systems].each do |id, val|
        @user.library_systems << LibrarySystem.find(id) if val
      end
      Resque.enqueue(UpdateUser, @user.id)
    end
    redirect_to :controller => :books, :action => :index
  end

  def locations
  end

  def save_locations
    @user.locations.clear
    if params[:locations]
      @user.locations = params[:locations].map {|l| Location.find(l) } 
    end
    redirect_to :controller => :books, :action => :index
  end

  private 
  def get_consumer 
    OAuth::Consumer.new(GOODREADS_API_KEY, 
                        GOODREADS_API_SECRET, 
                        :site => 'http://www.goodreads.com')
  end
end
