angular.module('minuteman.controllers').controller('BooksCtrl', ['$scope', 'Book', 'Location',
  ($scope, Book, Location) ->
    $scope.rowClass = (copy) ->
      'success' if copy.status.toLower() == 'available'

    $scope.atPreferredLocations = (copy) ->
      return true if Location.preferred().length == 0

      _.contains _.pluck(Location.preferred(), 'name'), copy.location_name

    $scope.books = Book.query()
])
