require 'spec_helper'

feature "viewing locations", js: true do

  context "with books at different locations" do
    before do
      @the_areas_of_my_expertise = create(:book, title: "The Areas of My Expertise", author: "John Hodgeman")
      @foucaults_pendulum = create(:book, title: "Foucault's Pendulum", author: "Umberto Eco")

      @cambridge = create(:location, name: "Cambridge", library_system: LibrarySystem::MINUTEMAN)
      @concord = create(:location, name: "Concord", library_system: LibrarySystem::MINUTEMAN)

      create(:copy, book: @the_areas_of_my_expertise, location: @cambridge, status: "In", title: @the_areas_of_my_expertise.title)
      create(:copy, book: @foucaults_pendulum, location: @cambridge, status: "In", title: @foucaults_pendulum.title)
      create(:copy, book: @foucaults_pendulum, location: @concord, status: "In", title: @foucaults_pendulum.title)

      @user = create(:user)
      @user.shelvings.create(book: @the_areas_of_my_expertise)
      @user.shelvings.create(book: @foucaults_pendulum)

      login @user
    end

    scenario "should only show books at first location" do
      visit location_path Location.find_by_name("Cambridge")
      expect(page.status_code).to eq(200)

      expect(page).to have_css('li.result', text: @the_areas_of_my_expertise.title)
      expect(page).to have_css('li.result', text: @foucaults_pendulum.title)
    end

    scenario "should only show books at second location" do
      visit location_path Location.find_by_name("Concord")
      expect(page.status_code).to eq(200)

      expect(page).to_not have_css('li.result', text: @the_areas_of_my_expertise.title)
      expect(page).to have_css('li.result', text: @foucaults_pendulum.title)
    end
  end
end
