require 'spec_helper'

describe WelcomeController do
  it "shows welcome index when logged out" do
    get :index
    expect(response).to be_ok
  end

  it "redirects to books when logged in" do
    session[:user_id] = Factory(:user).id
    get :index
    expect(response).to redirect_to(books_url)
  end
end
