angular.module('minuteman', [
  'ngRoute',
  'minuteman.controllers',
]).config ['$routeProvider', ($routeProvider) ->
  $routeProvider.
  when('/', {
    templateUrl: '/books',
    controller: 'BooksCtrl'
  }).
  otherwise({
    redirectTo: '/'
  })
]

angular.module('minuteman.controllers', [])
