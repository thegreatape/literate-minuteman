require 'test_helper'

class UsersIntegrationTest < ActionDispatch::IntegrationTest
  context "editing user preferences" do
    setup do
      @library_system = Factory(:library_system)
      @loc1 = Factory(:location, library_system: @library_system)
      @loc2 = Factory(:location, library_system: @library_system)
      @loc3 = Factory(:location, library_system: @library_system)

      @user = Factory(:user, library_systems: [@library_system])
      login @user
    end

    should "show all the locations" do
      visit "/users/#{@user.id}/edit"
      [@loc1, @loc2, @loc3].each do |loc|
        assert page.has_css?("input[name*=location_ids][value='#{loc.id}']")
      end

    end

    should "save locations" do
      visit "/users/#{@user.id}/edit"
      check @loc1.name
      check @loc2.name
      click_on 'Save'

      assert_equal books_url, current_url
      assert_equal 2, @user.reload.locations.length
      assert @user.locations.member? @loc1
      assert @user.locations.member? @loc2
    end

    should "overwrite existing choices" do
      @user.locations = [@loc1, @loc2]

      visit "/users/#{@user.id}/edit"
      check @loc2.name
      check @loc3.name
      click_on 'Save'

      assert_equal books_url, current_url
      assert_equal 2, @user.locations.length
      assert @user.locations.member? @loc1
      assert @user.locations.member? @loc2
    end
      
  end
end
