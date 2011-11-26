class UsersController < ApplicationController
  def signup
    render :signup && return unless request.post?

    @user = User.create(params[:user])
    if @user.save
      request_token = get_consumer.get_request_token
      @user.update_attribute(:oauth_token, request_token.token)
      @user.update_attribute(:oauth_secret, request_token.secret)
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
    @user.update_attributes(:goodreads_id => client.user_id,
                            :oauth_token => access_token.token,
                            :oauth_secret => access_token.secret)
    #Resque.enqueue(ShelfLookupWorker, goodreads_id)
    redirect_to '/'
  end


  def login
  end

  private 
  def get_consumer 
    OAuth::Consumer.new(GOODREADS_API_KEY, 
                        GOODREADS_API_SECRET, 
                        :site => 'http://www.goodreads.com')
  end
end
