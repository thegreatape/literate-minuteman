require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  context "user signups" do
    setup do
      Resque.stubs(:enqueue).returns(true)
      OAuth::Consumer.any_instance.stubs(:get_request_token).returns(
        Hashie::Mash.new({:token => 'token', 
                          :secret => 'secret', 
                          :authorize_url => 'authorize_url'}) )
    end

    context "that are successful" do
      setup do
        @email = 'oedipus@colonus.rex'
        @password = 'eyeballadornedbeard'
        post :signup, :user => {:email => @email, 
                                :password => @password, 
                                :password_confirmation => @password_confirmation}
      end

      should "create a user" do
        assert_equal 1, User.count
      end

      should "redirect to the goodreads oauth page" do
        assert_redirected_to 'authorize_url'
      end

      should "log in the user" do
        assert_equal User.find_by_email(@email).id, session[:user_id]
      end
    end

    should "not allow mismatched passwords" do
      post :signup, :user => {:email => 'oedipus@colonus.rex', 
                              :password => 'password', 
                              :password_confirmation => 'nope'}
      assert_template :signup
      assert_match /Password doesn't match confirmation/, @response.body
      assert_equal 0, User.count
    end

    should "not allow blank password confirmations" do
      post :signup, :user => {:email => 'oedipus@colonus.rex', 
                              :password => 'password', 
                              :password_confirmation => ''}
      assert_template :signup
      assert_match /Password doesn't match confirmation/, @response.body
      assert_equal 0, User.count
    end

    should "not allow duplicate users" do
      @email = 'oedipus@colonus.rex'
      Factory(:user, :email => @email)
      post :signup, :user => {:email => @email,
                              :password => 'password', 
                              :password_confirmation => 'password'}
      assert_template :signup
      assert_match /Email has already been taken/, @response.body
      assert_equal 1, User.where(:email => @email).count
    end
  end

  context "logging in" do
    context "with good credentials" do
      setup do
        @user = Factory(:user, :password => 'hi')
        post :login, :email => @user.email, :password => 'hi'
      end
      should "set the user id in the session" do
        assert_equal @user.id, session[:user_id]
      end

      should "redirect properly" do
        assert_redirected_to '/'
      end
    end

    should "fail with bad credentials" do
      @user = Factory(:user, :password => 'hi')
      post :login, :email => @user.email, :password => 'NOPE'
      assert_nil session[:user_id]
      assert_template :login
    end
  end
end
