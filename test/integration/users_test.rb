require 'test_helper'

class UsersIntegrationTest < ActionDispatch::IntegrationTest

  def save_systems(*args)
    visit "/users/#{@user.id}/edit"
    assert_equal 200, page.status_code

    [@system1, @system2, @system3].each {|s| uncheck(s.name)}
    args.each do |s|
      check(s.name)
    end

    click_on 'Save'
    @user.reload
  end

  context "editing user preferences" do
    setup do
      @system1 = Factory(:library_system)
      @system2 = Factory(:library_system)
      @system3 = Factory(:library_system)
      @loc1 = Factory(:location, library_system: @system1)
      @loc2 = Factory(:location, library_system: @system1)
      @loc3 = Factory(:location, library_system: @system1)

      @user = Factory(:user, library_systems: [@system1])
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

    should "overwrite existing location choices" do
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

    should "save for a single library system" do
      save_systems @system1
      assert @user.library_systems.member? @system1
      assert_equal 1, @user.library_systems.length
    end

    should "work for multiple library systems" do
      save_systems @system1, @system2, @system3
      assert @user.library_systems.member? @system1
      assert @user.library_systems.member? @system2
      assert @user.library_systems.member? @system3
      assert_equal 3, @user.library_systems.length
    end

    should "be able to change library systems" do
      save_systems @system1, @system2
      save_systems @system2, @system3
      assert @user.library_systems.member? @system2
      assert @user.library_systems.member? @system3
      assert_equal 2, @user.library_systems.length
    end

    should "be able to de-select all library systems" do
      save_systems @system1, @system2
      save_systems
      assert_equal 0, @user.library_systems.length
    end

    should "redirect back to books index" do
      save_systems @system1
      assert_equal books_url, current_url
    end

    should "save active shelves" do
      @user.shelves = ['to-read', 'wishlist']
      @user.save

      visit "/users/#{@user.id}/edit"
      check 'wishlist'
      click_on 'Save'

      assert_equal ['wishlist'], @user.reload.active_shelves
    end

  end
end
