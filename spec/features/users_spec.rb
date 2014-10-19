require 'spec_helper'

feature "users editing preferences", js: true do
  before do
    @system1 = LibrarySystem::MINUTEMAN
    @system2 = LibrarySystem::BOSTON

    @loc1 = create(:location, library_system_id: @system1.id)
    @loc2 = create(:location, library_system_id: @system1.id)
    @loc3 = create(:location, library_system_id: @system1.id)

    @loc4 = create(:location, library_system_id: @system2.id)

    @user = create(:user, library_system_ids: [@system1.id])
    login @user
  end

  scenario "show all the locations" do
    visit "/users/#{@user.id}/edit"
    should_have_locations @loc1, @loc2, @loc3
  end

  scenario "toggles locations when system is selected" do
    visit "/users/#{@user.id}/edit"
    should_have_locations @loc1, @loc2, @loc3
    uncheck @system1.name
    should_not_have_locations @loc1, @loc2, @loc3
    check @system1.name
    should_have_locations @loc1, @loc2, @loc3
    check @system2.name
    should_have_locations @loc1, @loc2, @loc3, @loc4
  end

  scenario "save locations" do
    visit "/users/#{@user.id}/edit"
    check @loc1.name
    check @loc2.name
    click_on 'Save'

    expect(current_path).to eq(books_path)
    expect(@user.reload.locations.length).to eq(2)
    expect(@user.locations).to include(@loc1)
    expect(@user.locations).to include(@loc2)
  end

  scenario "overwrite existing location choices" do
    @user.locations = [@loc1, @loc2]

    visit "/users/#{@user.id}/edit"
    check @loc2.name
    check @loc3.name
    click_on 'Save'

    expect(current_path).to eq(books_path)
    expect(@user.reload.locations.length).to eq(3)
    expect(@user.locations).to include(@loc1)
    expect(@user.locations).to include(@loc2)
    expect(@user.locations).to include(@loc3)
  end

  scenario "save for a single library system" do
    save_systems @system1
    expect(@user.reload.library_systems.length).to eq(1)
    expect(@user.library_systems).to include(@system1)
  end

  scenario "work for multiple library systems" do
    save_systems @system1, @system2
    expect(@user.reload.library_systems.length).to eq(2)
    expect(@user.library_systems).to include(@system1)
    expect(@user.library_systems).to include(@system2)
  end

  scenario "be able to change library systems" do
    save_systems @system1, @system2
    save_systems @system2
    expect(@user.reload.library_systems.length).to eq(1)
    expect(@user.library_systems).to include(@system2)
  end

  scenario "be able to de-select all library systems" do
    save_systems @system1, @system2
    save_systems
    expect(@user.library_systems).to be_empty
  end

  scenario "redirect back to books index" do
    save_systems @system1
    sleep 1
    expect(current_path).to eq(books_path)
  end

  scenario "save active shelves" do
    User.any_instance.stub(:sync_books)
    @user.shelves = ['to-read', 'wishlist']
    @user.save

    visit "/users/#{@user.id}/edit"
    check 'wishlist'
    click_on 'Save'

    expect(@user.reload.active_shelves).to eq ['wishlist']
  end

  def should_have_locations(*locations)
    locations.each do |loc|
      expect(page).to have_css("input[name*=location_ids][value='#{loc.id}']")
    end
  end

  def should_not_have_locations(*locations)
    locations.each do |loc|
      expect(page).to_not have_css("input[name*=location_ids][value='#{loc.id}']")
    end
  end

  def save_systems(*args)
    visit "/users/#{@user.id}/edit"
    expect(page.status_code).to eq(200)

    [@system1, @system2].each {|s| uncheck(s.name)}
    args.each do |s|
      check(s.name)
    end

    click_on 'Save'
    @user.reload
  end
end
