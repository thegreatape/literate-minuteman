angular.module('minuteman.services').factory('Book', [ '$resource', 'Location',
  ($resource, Location) ->
    $resource('/books/:id.json', {}, {})
])
