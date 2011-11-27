require 'test_helper'

class BooksControllerTest < ActionController::TestCase
  should "redirect to login without auth" do
    get :index
    assert_redirected_to :controller => :users, :action => :login
  end

  should "render index when logged in" do
    login Factory(:user)
    get :index
    assert_response :ok
  end

end
