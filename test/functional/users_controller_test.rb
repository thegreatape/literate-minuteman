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

  context "saving library systems" do

    setup do
      @user = Factory(:user)
      login @user
      @system1 = Factory(:library_system)
      @system2 = Factory(:library_system)
      @system3 = Factory(:library_system)
    end

    should "work for a single system" do
      save_systems @system1
      assert @user.library_systems.member? @system1
      assert_equal 1, @user.library_systems.length
    end

    should "work for multiple systems" do
      save_systems @system1, @system2, @system3
      assert @user.library_systems.member? @system1
      assert @user.library_systems.member? @system2
      assert @user.library_systems.member? @system3
      assert_equal 3, @user.library_systems.length
    end

    should "be able to change systems" do
      save_systems @system1, @system2
      save_systems @system2, @system3
      assert @user.library_systems.member? @system2
      assert @user.library_systems.member? @system3
      assert_equal 2, @user.library_systems.length
    end

    should "be able to de-select all systems" do
      save_systems @system1, @system2
      save_systems
      assert_equal 0, @user.library_systems.length
    end

    should "redirect back to books index" do
      save_systems @system1
      assert_redirected_to :controller => :books, :action => :index
    end
  end

  private
  def save_systems(*args)
    systems = Hash[ args.map{|s| [s.id, true]} ]
    post :save_library_systems, :systems => systems
    @user.reload
  end
end
