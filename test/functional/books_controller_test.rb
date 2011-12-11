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

  should "show the library system picker if user has no systems" do
    login Factory(:user, :library_systems => [])
    get :index
    assert_response :ok
    assert_select 'body', :matches => /Check the library systems you're a part of/
  end

  context "with books" do
    setup do
      @user = Factory(:user)
      3.times do |i|
        book = Factory(:book, :user => @user, :title => "Book #{i}")
        copies = 2.times {|i| Factory(:copy, :book => book) }
      end
      book = Factory(:book, :user => @user, :title => "Book With No Copies")

      login @user
      get :index
    end

    should "display all my books with copies" do
      assert_select '.book-result', :count => 3
    end

    should "display all my books without copies" do
      assert_select '.no-results', :matches => /Book With No Copies/
    end
  end

  context "with custom locations set" do
    setup do
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
      login @user
    end

    should "only show books with copies at my locations" do
      @user.locations = [Location.find_by_name("Concord")]
      get :index
      assert_select ".book-result h2", /#{@list[1][:title]}/
      assert_select ".book-result h2", :text => /#{@list[0][:title]}/, :count => 0
    end

    should "only show the copies of the books at my locations" do
      @user.locations = [Location.find_by_name("Cambridge")]
      get :index
      assert_select ".book-result h2", /#{@list[0][:title]}/
      assert_select ".book-result h2", /#{@list[1][:title]}/
      assert_select ".locations ul li", :text => "Cambridge", :count => 2
      assert_select ".locations ul li", :text => "Concord", :count => 0
    end
  end

end
