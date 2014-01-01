require 'spec_helper'

describe LocationsController do
  render_views

  context "with books at different locations" do
    before do
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
      @user = Factory(:user)
      @library_system = Factory(:library_system)
      @user.sync_books @list, @library_system
      session[:user_id] = @user.id
    end

    it "should only show books at first location" do
      get :show, :id => Location.find_by_name("Cambridge")
      assert_response :ok

      assert_select 'li.result', /#{@list[0][:title]}/ 
      assert_select 'li.result', /#{@list[1][:title]}/ 
    end

    it "should only show books at second location" do
      get :show, :id => Location.find_by_name("Concord")
      assert_response :ok

      assert_select 'li.result', :text => /#{@list[0][:title]}/, :count => 0
      assert_select 'li.result', /#{@list[1][:title]}/ 
    end
  end
end
