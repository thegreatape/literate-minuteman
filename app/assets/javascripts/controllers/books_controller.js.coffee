angular.module('minuteman.controllers').controller('BooksCtrl', ['$scope', 'Book', 'Location',
  ($scope, Book, Location) ->
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
        show = show && copy.status.toLowerCase() == 'available'

      show

    $scope.books = Book.query()
])
