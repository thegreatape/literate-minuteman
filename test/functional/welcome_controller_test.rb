require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "show welcome index when logged out" do
    get :index
    assert_response :ok
  end

  test "redirect to books when logged in" do 
    login Factory(:user)
    get :index
    assert_redirected_to books_url
  end
end
