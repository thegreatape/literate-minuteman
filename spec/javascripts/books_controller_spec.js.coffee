describe "BooksCtrl", ->
  beforeEach module('minuteman.controllers')

  beforeEach =>
    @preferredLocations = []
    @pusherMock = {
      subscribe: =>
    }

    @locationMock = {
      preferred: => @preferredLocations
    }

    @lexicon = {
      title: "Lexicon",
      author: "Max Barry",
      copies: [
        { status: "AVAILABLE", location_name: "Cambridge"}
      ]
    }

    @books = [ @lexicon ]
    @bookMock = {
      query: => @books
    }


  beforeEach inject ($rootScope, $controller) =>
    @scope = $rootScope.$new()
    @controller = $controller('BooksCtrl', {
      $scope: @scope, Book: @bookMock, Location: @locationMock, Pusher: @pusherMock
    })

  it "adds all books to the scope", =>
    expect(@scope.books).toEqual @books

  describe "copy filtering", =>
    it "returns all copies with no preferred locations set", =>
      expect(@scope.copyFilter(@lexicon.copies[0])).toBeTruthy()

    describe "copy location filtering", =>

      it "is enabled by default", =>
        expect(@scope.onlyShowCopiesAtPreferredLocations).toBeTruthy()

      it "returns true only for copies contained in the preferred locations", =>
        @preferredLocations = [{name: "Cambridge"}]
        expect(@scope.copyFilter(@lexicon.copies[0])).toBeTruthy()
        expect(@scope.copyFilter({location_name: "Central Square"})).toBeFalsy()

      it "returns true for all copies when flag is unset", =>
        @preferredLocations = [{name: "Cambridge"}]
        @scope.onlyShowCopiesAtPreferredLocations = false
        @scope.$digest()

        expect(@scope.copyFilter(@lexicon.copies[0])).toBeTruthy()
        expect(@scope.copyFilter({location_name: "Central Square"})).toBeTruthy()

    describe "copy availability filtering", =>

      it "is disabled by default", =>
        expect(@scope.onlyShowAvailableCopies).toBeFalsy()

      it "returns true for only available copies", =>
        @scope.onlyShowAvailableCopies = true
        expect(@scope.copyFilter({status: "Out"})).toBeFalsy()
        expect(@scope.copyFilter({status: "AVAILABLE"})).toBeTruthy()
        expect(@scope.copyFilter({status: "In"})).toBeTruthy()
        expect(@scope.copyFilter({status: "In-Recent Return"})).toBeTruthy()

      it "returns true for all copies when flag is unset", =>
        expect(@scope.copyFilter({status: "Out"})).toBeTruthy()
