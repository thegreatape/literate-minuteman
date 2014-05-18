angular.module('minuteman.controllers').controller('BooksCtrl', ['$scope', 'Book', 'Location',
  ($scope, Book, Location) ->
    $scope.rowClass = (copy) ->
      'success' if copy.status.toLower() == 'available'

    $scope.bookFilter = (book) ->
      _.filter(book.copies, $scope.copyFilter).length > 0

    $scope.copyFilter = (copy) ->
      return true if Location.preferred().length == 0

      _.contains _.pluck(Location.preferred(), 'name'), copy.location_name

    $scope.books = Book.query()
])
