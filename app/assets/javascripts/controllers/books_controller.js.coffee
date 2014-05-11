angular.module('minuteman.controllers').controller('BooksCtrl', ['$scope', 'Book',
  ($scope, Book) ->
    $scope.rowClass = (copy) ->
      'success' if copy.status.toLower() == 'available'

    $scope.books = Book.query()
])
