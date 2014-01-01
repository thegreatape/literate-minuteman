require 'spec_helper'

describe BooksController do
  render_views

  it "redirect to login without auth" do
    get :index
    assert_redirected_to :controller => :users, :action => :login
  end

  it "render index when logged in" do
    session[:user_id] = Factory(:user).id
    get :index
    assert_response :ok
  end

  it "show the library system picker if user has no systems" do
    session[:user_id] = Factory(:user, :library_systems => []).id
    get :index
    assert_response :ok
    assert_select 'body', :matches => /Check the library systems you're a part of/
  end

  context "with books" do
    before do
      @user = Factory(:user)
      3.times do |i|
        book = Factory(:book, :user => @user, :title => "Book #{i}")
        copies = 2.times {|i| Factory(:copy, :book => book) }
      end
      book = Factory(:book, :user => @user, :title => "Book With No Copies")

      session[:user_id] = @user.id
      get :index
    end

    it "display all my books with copies" do
      assert_select '.book-result', :count => 3
    end

    it "display all my books without copies" do
      assert_select '.no-results', :matches => /Book With No Copies/
    end
  end

  context "with custom locations set" do
    before do
      @user = Factory(:user)
      @list = [
        {:title => "The Areas of My Expertise",
         :author => "John Hodgeman",
         :copies => [
           {:title => "The Areas of My Expertise",
            :status => "In",
            :location => "Cambridge"}
          ]},
        {:title => "Foucault's Pendulum",
         :author => "Umberto Eco",
         :copies => [
           {:title => "Foucault's Pendulum",
            :status => "In",
            :location => "Cambridge"},
           {:title => "Foucault's Pendulum",
            :status => "In",
            :location => "Concord"}
          ]}
      ]
      @library_system = Factory(:library_system)
      @user.sync_books @list, @library_system 
      session[:user_id] = @user.id
    end

    it "only shows books with copies at my locations" do
      @user.locations = [Location.find_by_name("Concord")]
      get :index
      assert_select ".book-result h2", /#{@list[1][:title]}/
      assert_select ".book-result h2", :text => /#{@list[0][:title]}/, :count => 0
    end

    it "only shows the copies of the books at my locations" do
      @user.locations = [Location.find_by_name("Cambridge")]
      get :index
      assert_select ".book-result h2", /#{@list[0][:title]}/
      assert_select ".book-result h2", /#{@list[1][:title]}/
      assert_select ".locations ul li", :text => "Cambridge", :count => 2
      assert_select ".locations ul li", :text => "Concord", :count => 0
    end
  end

end
