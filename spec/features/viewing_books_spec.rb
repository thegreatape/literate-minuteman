require 'spec_helper'

feature "viewing books", js: true do

  scenario "redirecting to login without auth" do
    visit books_path
    expect(current_path).to eq(root_path)
  end

  context "without books" do
    scenario "showing the library system picker if user has no systems" do
      user = create(:user, :library_system_ids => [])
      login user

      visit books_path
      expect(page.status_code).to eq(200)
      expect(page).to have_content("Check the library systems that you're a part of")
    end
  end

  context "with books" do
    before do
      @user = create(:user)
      3.times do |i|
        book = create(:book, title: "Book #{i}")
        copies = 2.times {|i| create(:copy, book: book) }
        @user.shelvings.create(book: book)
      end
      book = create(:book, title: "Book With No Copies")
      @user.shelvings.create(book: book)

      login @user
      visit books_path
    end

    it "display all my books with copies" do
      expect(page.all('.book-result').length).to eq(3)
    end

    it "display all my books without copies" do
      within '.no-results' do
        expect(page).to have_content "Book With No Copies"
      end
    end
  end

  context "with custom locations set" do
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

    it "only shows books with copies at my locations" do
      @user.update_attributes(locations: [Location.find_by_name("Concord")])
      visit books_path

      within '.book-result' do
        page.should have_content @foucaults_pendulum.title
        page.should_not have_content @the_areas_of_my_expertise.title
      end

      within '.no-results' do
        page.should_not have_content @foucaults_pendulum.title
        page.should have_content @the_areas_of_my_expertise.title
      end

      @user.update_attributes(locations: [Location.find_by_name("Cambridge")])
      visit books_path

      page.should have_css ".book-result", text: @foucaults_pendulum.title
      page.should have_css ".book-result", text: @the_areas_of_my_expertise.title

      page.should_not have_css ".no-results"
    end
  end
end
