angular.module('minuteman.services').factory('Location', [ '$resource',
  ->
    {
      normalizeName: (locationName) ->
        locationName
    }
])
