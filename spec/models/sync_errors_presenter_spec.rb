require 'spec_helper'

describe SyncErrorsPresenter do
  before do
    @no_errors_book = create(:book, sync_errors: {})
    @boston_errors_book = create(:book, sync_errors: {
      LibrarySystem::BOSTON.id => "ruh roh"
    })
    @boston_and_minuteman_errors_book = create(:book, sync_errors: {
      LibrarySystem::BOSTON.id => "ruh roh",
      LibrarySystem::MINUTEMAN.id => "egad"
    })

    @presenter = SyncErrorsPresenter.new
  end

  describe "#library_systems" do
    it "returns a list of LibrarySystem whose books have sync_errors" do
      expect(@presenter.library_systems).to match_array([
        LibrarySystem::BOSTON, LibrarySystem::MINUTEMAN
      ])
    end
  end

  describe "[]" do
    it "returns the books with errors for the given library system" do
      expect(@presenter[LibrarySystem::BOSTON]).to match_array [
        @boston_errors_book,
        @boston_and_minuteman_errors_book
      ]
      expect(@presenter[LibrarySystem::MINUTEMAN]).to match_array [@boston_and_minuteman_errors_book]
      expect(@presenter[LibrarySystem::BOSTON_OVERDRIVE]).to be_empty
    end
  end
end
