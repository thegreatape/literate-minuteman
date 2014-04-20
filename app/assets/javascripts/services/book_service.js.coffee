angular.module('minuteman.services').factory('Book', [ '$resource'
  ($resource) ->
    $resource('/books/:id.json', {}, {})
])
