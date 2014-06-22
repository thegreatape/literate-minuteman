angular.module('minuteman', [
  'minuteman.controllers',
  'minuteman.services',
  'angularMoment',
  'doowb.angular-pusher'
]).config(['PusherServiceProvider', (PusherServiceProvider) ->
  if window.Minuteman
    PusherServiceProvider.setToken(Minuteman.pusherKey).setOptions({})
])

angular.module('minuteman.controllers', [])
angular.module('minuteman.services', ['ngResource'])
