angular.module('minuteman.services').factory('Location', [ '$resource',
  ->
    {
      preferred:->
        Minuteman.preferredLocations
    }
])
