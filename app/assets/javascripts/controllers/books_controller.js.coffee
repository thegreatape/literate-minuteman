angular.module('minuteman.controllers').controller('BooksCtrl', ['$scope', 'Book', 'Location', 'Pusher'
  ($scope, Book, Location, Pusher) ->
    $scope.onlyShowCopiesAtPreferredLocations = true

    $scope.rowClass = (copy) ->
      'success' if copy.status.toLowerCase() == 'available'

    $scope.bookFilter = (book) ->
      _.filter(book.copies, $scope.copyFilter).length > 0

    $scope.copyFilter = (copy) ->
      show = true

      if $scope.onlyShowCopiesAtPreferredLocations && Location.preferred().length > 0
        show = _.contains _.pluck(Location.preferred(), 'name'), copy.location_name

      if $scope.onlyShowAvailableCopies
        status = copy.status.toLowerCase()
        show = show && status.match /available|^in/

      show

    $scope.books = Book.query()

    Pusher.subscribe Minuteman.bookUpdateChannel, 'book-updated', (updatedBook) ->
      for book, i in $scope.books
        if book.id == updatedBook.id
          return $scope.books[i] = updatedBook
      $scope.books.push updatedBook

    $scope.pendingBookCount = Minuteman.initialPendingBookCount
    Pusher.subscribe Minuteman.pendingBooksChannel, 'pending-count-updated', (update) ->
      $scope.pendingBookCount = update.count
])
