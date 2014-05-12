describe "Location", ->
  beforeEach module('minuteman.services')

  beforeEach =>
    @location = angular.injector(['minuteman.services']).get('Location')

  it "normalizes location names", =>
    expect(@location.normalizeName('CAMBRIDGE/New Books')).toEqual 'Cambridge'

