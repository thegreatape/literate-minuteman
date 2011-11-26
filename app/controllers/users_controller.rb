class UsersController < ApplicationController
  def signup
    render :signup && return unless request.post?

    @user = User.create(params[:user])
    if @user.save
      consumer = OAuth::Consumer.new(GOODREADS_API_KEY, 
                                     GOODREADS_API_SECRET, 
                                     :site => 'http://www.goodreads.com')
      request_token = consumer.get_request_token
      @user.update_attribute(:oauth_token, Marshal.dump(request_token))
      redirect_to request_token.authorize_url
    else
      render :signup
    end
  end

  def oauth_callback
    @user = User.where("oauth_token ilike ?", "%#{params[:oauth_token]}%").first
    request_token = Marshal.load(data['token'])
    access_token = request_token.get_access_token
    client = Goodreads::Client.new(access_token)
    @user.update_attributes(:goodreads_id => client.user_id,
                            :oauth_token => access_token.token,
                            :oauth_secret => access_token.secret)
    #Resque.enqueue(ShelfLookupWorker, goodreads_id)
    redirect '/'
  end


  def login
  end
end
