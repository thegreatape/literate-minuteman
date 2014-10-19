angular.module('minuteman.controllers').controller('BooksCtrl', ['$scope', 'Book', 'Location', 'Pusher'
  ($scope, Book, Location, Pusher) ->
    $scope.onlyShowCopiesAtPreferredLocations = true

    $scope.available_locations = Location.preferred()
    $scope.$watch 'onlyShowCopiesAtPreferredLocations', ->
      if $scope.onlyShowCopiesAtPreferredLocations
        $scope.available_locations = Location.preferred()
      else
        $scope.available_locations = Location.all()


    $scope.rowClass = (copy) ->
      'success' if $scope.isAvailable(copy)

    $scope.bookFilter = (book) ->
      _.filter(book.copies, $scope.copyFilter).length > 0

    $scope.copyFilter = (copy) ->
      show = true

      if $scope.onlyShowCopiesAtPreferredLocations && Location.preferred().length > 0
        show = _.contains _.pluck(Location.preferred(), 'name'), copy.location_name

      if $scope.location
        show = show && copy.location_name == $scope.location

      if $scope.onlyShowAvailableCopies
        show = show && $scope.isAvailable(copy)

      show

    $scope.isAvailable = (copy) ->
      status = copy.status.toLowerCase()
      status.match /available($|:\s*[123456789]+)|^in/

    $scope.books = Book.query()

    Pusher.subscribe Minuteman.bookUpdateChannel, 'book-updated', (message) ->
      for book, i in $scope.books
        if book.id == message.id
          return Book.get {id: message.id}, (updatedBook) ->
            $scope.books[i] = updatedBook
      $scope.books.push updatedBook

    $scope.pendingBookCount = Minuteman.initialPendingBookCount
    Pusher.subscribe Minuteman.pendingBooksChannel, 'pending-count-updated', (update) ->
      $scope.pendingBookCount = update.count
])
